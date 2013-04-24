require 'feedzirra'

module RubyTapasProxy
  module RubyTapas
    class RSSFeed

      def initialize config, site_url
        @config = config
        @ruby_tapas_config = config.ruby_tapas
        @site_url = site_url
      end

      def load
        rewrite_urls(fetch)
      end

      private

      attr_reader :config, :ruby_tapas_config, :site_url

      def rewrite_urls input
        regex = Regexp.new('"(' + ruby_tapas_config.download_base_url + '/[^"]+)"')
        input.gsub(regex, '"' + "#{site_url}/download?api_key=#{config.api_key}&amp;url=" + '\1"')
      end

      def fetch
        Feedzirra::Feed.fetch_raw(
          ruby_tapas_config.feed_url,
          :http_authentication => [ ruby_tapas_config.username, ruby_tapas_config.password ]
        )
      end
    end
  end
end
