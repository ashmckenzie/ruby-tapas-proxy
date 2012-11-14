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

  # '<a href="/bypass-protection?api_key=' + params[:api_key] + '">Protected!</a>'
end

# get '/bypass-protection' do
#   http = Net::HTTP.new('localhost', 9393)

#   request = Net::HTTP::Get.new('/protected?api_key=757b760e97feee5b5e00bfc9dc3dc38f')
#   request.basic_auth 'admin', 'admin'

#   x = http.request(request)
#   x.body
# end

# get '/protected' do
#   protected!
#   "You've broken my protection!"
# end

get '/download' do
  content_type 'application/octet-stream'

  episode = RubyTapasProxy::Episode.new(params[:url], config.username, config.password, { :ssl => true })

  attachment(episode.filename)
  response['Content-Length'] = params[:length]

  stream do |out|
    episode.download do |response|
      response.read_body do |chunk|
        out << chunk
      end
    end
  end
end

def config
  $APP_CONFIG.ruby_tapas
end
