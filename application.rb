require 'sinatra'
require 'sinatra/json'
require 'sinatra/sequel'
require "sinatra/config_file"
require 'tropo-webapi-ruby'
require 'httparty'

config_file 'config/config.yml'

# Autoload Directories
autoload = %w(lib models)
autoload.each do |directory|
  Dir[File.dirname(__FILE__) + "/#{directory}/*.rb"].each { |file| require file }
end

# To manage the web session coookies
use Rack::Session::Pool

get '/' do
  "Welcome to Tropo Customer Survey App POC:<br /><br />We've taken #{Survey.count} surveys with #{Question.filter(response: nil).invert.count} responses!"
end

post '/' do
  phone = params[:phone]
  error(400, 'Invalid phone number') if phone.nil?

  questions = params[:questions]
  error(400, 'No questions submitted') if questions.nil? || questions.count < 1

  survey = Survey.create(phone_number: phone)
  questions.each { |q| survey.add_question(value: q) }

  logger.info "Starting a new survey with phone number: #{phone}"
  HTTParty.get "http://api.tropo.com/1.0/sessions?action=create&token=#{settings.tropo_app_token}&survey=#{survey.id}"

  json survey_id: survey.id
end

post '/call_out.json' do

  v = Tropo::Generator.parse request.env["rack.input"].read
  survey = Survey[v[:session][:parameters][:survey]]
  session[:survey_id] = survey.id
  session[:question] = 1

  t = Tropo::Generator.new
  t.call(to: "+#{survey.phone_number}")
  t.say(value: 'We are going to ask you some questions.  You can speak or type in your answers.  Press pound to continue to the next question.')
  question_json session[:question], t, survey
end

post '/ask_another_question.json' do

  # Get the previous questions response and save it.
  v = Tropo::Generator.parse request.env["rack.input"].read
  survey = Survey[session[:survey_id]]
  response = v[:result][:actions][:question][:value] rescue nil
  survey.questions[session[:question]-1].update(response: response) unless response.nil?

  # Ask the next question.
  t = Tropo::Generator.new
  session[:question] += 1

  if survey.questions[session[:question]-1].nil?
    t.say(value: "Thank you for completing our survey.")
    t.hangup
  else
    question_json session[:question], t, survey
  end
end

get '/results/:survey' do
  survey = Survey[params[:survey]]
  json survey.nil? ? error(404, 'Survey Not Found') : survey.to_json
end

private

  def question_json(question, tropo, survey)
    logger.info "Asking question #{question} which is #{survey.questions[question-1].value}"
    tropo.ask name: "question",
          attempts: 2,
          say:  [
                  { value: "Sorry. I didn't get that.", event: 'timeout' },
                  { value: "Sorry. That wasn't a valid answer.", event: 'nomatch:1 nomatch:2' }
                  { value: "Number #{question}: #{survey.questions[question-1].value}" },
                ],
          choices: { value: "[1-20 DIGITS]"}
    tropo.on event: 'continue', next: "/ask_another_question.json"
    tropo.response
  end
