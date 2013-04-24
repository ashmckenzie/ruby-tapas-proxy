require 'uri'

module RubyTapasProxy
  module RubyTapas
    class Episode

      extend Forwardable

      def initialize url
        @uri = URI.parse(url)
      end

      def filename
        uri.path.split('/').last
      end

      def redirect_url
        "/remote-download/#{scheme}/#{host}#{path}"
      end

      def_delegators :@uri, :scheme, :host, :path

      private

      attr_reader :uri

    end
  end
end
