require 'sinatra'
require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, Sinatra::Application.environment)

if File.exists?('.env')
  Dotenv.load('.env')
end

unless ENV.has_key?('DATABASE_URL')
  puts "ENV['DATABASE_URL'] is undefined.  Make sure your .env file is correct."
  exit 1
end

DataMapper.setup(:default, ENV['DATABASE_URL'])

if Sinatra::Application.development?
  DataMapper::Logger.new($stdout, :debug)
end
