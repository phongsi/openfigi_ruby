# frozen_string_literal: true

require_relative "openfigi_ruby/version"
require_relative "openfigi_ruby/configuration"
require_relative "openfigi_ruby/error"
require_relative "openfigi_ruby/figi_result"
require_relative "openfigi_ruby/mapping_result"
require_relative "openfigi_ruby/search_result"
require_relative "openfigi_ruby/client"

module OpenfigiRuby
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    # Configures the gem globally.
    #
    # @example
    #   OpenfigiRuby.configure do |config|
    #     config.api_key = ENV["OPENFIGI_API_KEY"]
    #   end
    def configure
      yield configuration
    end
  end
end
