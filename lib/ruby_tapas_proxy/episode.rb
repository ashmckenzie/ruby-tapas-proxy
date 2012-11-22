module RubyTapasProxy
  class Episode

    attr_reader :uri

    def initialize url, opts={}
      @uri = URI.parse(url)
      @opts = opts
    end

    def filename
      uri.path.split('/').last
    end

    def scheme
      uri.scheme
    end

    def host
      uri.host
    end

    def path
      uri.path
    end
  end
end
