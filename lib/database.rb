configure :development do
  set :database, "sqlite://db/survey_#{Sinatra::Base.environment}.db"
end
