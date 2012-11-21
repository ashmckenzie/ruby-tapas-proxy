require 'bundler/setup'
Bundler.require(:default, :development)

require 'sinatra/streaming'

Dir['./config/initialisers/*.rb'].each { |f| require f }

before do
  halt 401, 'Access denied' unless $APP_CONFIG.api_keys.include? params[:api_key]
  @api_key = params[:api_key]
end

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end
end

get '/' do
  # Nothing :)
end

get '/feed' do
  content_type 'application/rss+xml'

  site_url = RubyTapasProxy::Feed.site_url_from_request(request)
  RubyTapasProxy::Feed.get(params[:api_key], config.feed_url, config.username, config.password, site_url)
end

get '/download' do
  cache_control 'no-cache'
  content_type 'application/octet-stream'

  episode = RubyTapasProxy::Episode.new(params[:url], config.username, config.password, { :ssl => true })

  attachment(episode.filename)
  response['Content-Length'] = params[:length]

  stream do |out|
    episode.download do |chunk|
      out << chunk
    end
  end
end

def config
  $APP_CONFIG.ruby_tapas
end
