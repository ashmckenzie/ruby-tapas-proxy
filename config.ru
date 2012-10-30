require 'bundler/setup'
Bundler.require(:default, :development)

require './app'
run Sinatra::Application

