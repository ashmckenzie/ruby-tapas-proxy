module RubyTapasProxy
  class Feed
    def self.get api_key, url, username, password, site_url
      raw = Feedzirra::Feed.fetch_raw(url, :http_authentication => [ username, password ])
      # regex = Regexp.new('"(' + RubyTapasProxy::RUBY_TAPAS_DOWNLOAD_BASE_URL + '/[^"]+)" length="(\d+)"')
      # raw.gsub(regex, '"' + "#{site_url}/download?api_key=#{api_key}&amp;url=" + '\1' + "&amp;length=" + '\2" length="\2"')
      regex = Regexp.new('"(' + RubyTapasProxy::RUBY_TAPAS_DOWNLOAD_BASE_URL + '/[^"]+)"')
      raw.gsub(regex, '"' + "#{site_url}/download?api_key=#{api_key}&amp;url=" + '\1')
    end

    def self.site_url_from_request request
      "#{request.scheme}://#{request.host}#{[ 80, 8080 ].include?(request.port) ? '' : ":#{request.port}"}"
    end
  end
end
