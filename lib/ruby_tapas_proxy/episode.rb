module RubyTapasProxy
  class Episode

    attr_reader :uri

    def initialize url, username, password, opts={}
      @uri = URI.parse(url)
      @username = username
      @password = password
      @opts = opts
    end

    def filename
      uri.path.split('/').last
    end

    def download
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = @opts[:ssl]

      request = Net::HTTP::Get.new(uri.request_uri, { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17' })
      request.basic_auth @username, @password

      yield http.request(request)
    end
  end
end
