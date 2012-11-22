require 'bundler/setup'
Bundler.require(:default, :development)

require 'base64'
# require 'sinatra/streaming'

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
  episode = RubyTapasProxy::Episode.new(params[:url], { :ssl => true })

  encoded_auth = Base64.encode64("#{config.username}:#{config.password}").strip

  # headers['Content-Length'] = params[:length]

  headers['Authorization'] = %Q{Basic "#{encoded_auth}"}
  headers['Content-Disposition'] = %Q{attachment; filename="#{episode.filename}"}
  # headers['X-Accel-Redirect'] = "/remote-download/#{episode.scheme}/#{episode.host}#{episode.path}"
  headers['X-Accel-Redirect'] = "/remote-download?url=#{episode.uri.to_s}"

  ''
end

private

def config
  $APP_CONFIG.ruby_tapas
end
