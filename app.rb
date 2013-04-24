require 'forwardable'
require 'bundler/setup'
Bundler.require(:default)

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib/ruby_tapas_proxy/')

require 'config/base'
require 'ruby_tapas/rss_feed'
require 'ruby_tapas/episode'

CONFIG = RubyTapasProxy::Config::Base.new

before do
  halt 401, 'Access denied' unless CONFIG.api_key_valid?(params[:api_key])
end

get '/' do
  # Nothing :)
end

get '/feed' do
  content_type 'application/rss+xml'

  site_url = "#{request.scheme}://#{request.host}#{[ 80, 8080 ].include?(request.port) ? '' : ":#{request.port}"}"
  RubyTapasProxy::RubyTapas::RSSFeed.new(CONFIG, site_url).load
end

get '/download' do
  episode = RubyTapasProxy::RubyTapas::Episode.new(params[:url])

  headers['X-Auth'] = CONFIG.ruby_tapas.base64_encoded_auth
  headers['X-Accel-Redirect'] = episode.redirect_url

  ''
end
