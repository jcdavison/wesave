require File.expand_path(File.join(*%w[ config setup ]), File.dirname(__FILE__))

run Sinatra::Application
