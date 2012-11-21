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
      Curl::Easy.http_get uri.to_s do |c|
        c.http_auth_types = :basic
        c.username = @username
        c.password = @password
        c.on_body do |data|
          # out << data
          yield data
          data.size
        end
      end
    end
  end
end
