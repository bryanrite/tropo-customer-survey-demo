require 'sinatra'
require 'sinatra/json'
require 'sinatra/sequel'
require "sinatra/config_file"

config_file 'config/config.yml'

# Autoload Directories
autoload = %w(lib models)
autoload.each do |directory|
  Dir[File.dirname(__FILE__) + "/#{directory}/*.rb"].each { |file| require file }
end

get '/' do
  "Welcome to Tropo Customer Survey App POC"
end

# post '/'