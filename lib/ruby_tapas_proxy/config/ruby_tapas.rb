require 'base64'

module RubyTapasProxy
  module Config
    class RubyTapas

      attr_reader :subscriber_url, :feed_url, :download_base_url, :username, :password

      def initialize config
        @subscriber_url = config.subscriber_url
        @feed_url = config.feed_url
        @download_base_url = config.download_base_url
        @username = config.username
        @password = config.password
      end

      def base64_encoded_auth
        encoded = Base64.encode64("#{username}:#{password}").strip
        %Q{Basic #{encoded}}
      end
    end
  end
end
