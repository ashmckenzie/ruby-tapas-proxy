require 'yaml'
require 'hashie'

require_relative './ruby_tapas'

module RubyTapasProxy
  module Config
    class Base

      extend Forwardable

      def initialize file=default_file
        @config = Hashie::Mash.new(YAML.load_file(file))
      end

      def ruby_tapas
        @ruby_tapas ||= RubyTapas.new(config.ruby_tapas)
      end

      def api_key_valid? key
        config.api_key == key
      end

      def_delegators :@config, :api_key

      private

      attr_reader :config

      def default_file
        File.expand_path('../../../../config/config.yml', __FILE__)
      end
    end
  end
end
