require 'httparty'
require 'json'

base_uri = "http://localhost:4567"

questions = ["When were you born", "How many siblings do you have", "What is your favourite number"]

response = HTTParty.post base_uri, query: { phone: '15551234567', questions: questions }

puts "You can check #{base_uri}/results/#{JSON.parse(response.body)['survey_id']} for your survey results in a few minutes!"