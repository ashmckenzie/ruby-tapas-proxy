require 'bundler/setup'
Bundler.require(:default, :development)

Dir['./config/initialisers/*.rb'].each { |f| require f }

get '/feed' do
  content_type 'application/rss+xml'

  raw = Feedzirra::Feed.fetch_raw(
    $APP_CONFIG.ruby_tapas.feed_url,
    :http_authentication => [
      $APP_CONFIG.ruby_tapas.username,
      $APP_CONFIG.ruby_tapas.password
    ]
  )
  # feed = Feedzirra::Parser::ITunesRSS.parse(raw)
  site = "#{request.scheme}://#{request.host}#{request.port == 80 ? '' : ":#{request.port}"}"
  raw.gsub(/\"(https:\/\/rubytapas.dpdcart.com\/feed\/download\/.+)\"/, '"' + "#{site}/download?url=" + '\1"')
end

get '/download' do
  content_type 'application/octet-stream'

  uri = URI.parse(params[:url])

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth $APP_CONFIG.ruby_tapas.username, $APP_CONFIG.ruby_tapas.password

  file_name = uri.path.split('/').last
  attachment(file_name)

  stream do |out|
    http.request(request) do |response|
      response.read_body do |chunk|
        out << chunk
      end
    end
  end
end
