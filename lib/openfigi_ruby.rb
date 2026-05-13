# frozen_string_literal: true

require_relative "openfigi_ruby/version"
require_relative "openfigi_ruby/configuration"
require_relative "openfigi_ruby/error"
require_relative "openfigi_ruby/figi_result"
require_relative "openfigi_ruby/mapping_result"
require_relative "openfigi_ruby/search_result"
require_relative "openfigi_ruby/client"

# Ruby client for the OpenFIGI V3 API.
#
# Provides identifier mapping, keyword search, and filtering for Financial
# Instrument Global Identifiers (FIGIs).
#
# @example Configure globally and create a client
#   OpenfigiRuby.configure do |config|
#     config.api_key = ENV["OPENFIGI_API_KEY"]
#   end
#
#   client = OpenfigiRuby::Client.new
#   results = client.mapping([{ id_type: "ID_ISIN", id_value: "US0378331005" }])
module OpenfigiRuby
  class << self
    # Returns the global {Configuration} instance.
    # @return [Configuration]
    def configuration
      @configuration ||= Configuration.new
    end

    # Configures the gem globally.
    #
    # @example
    #   OpenfigiRuby.configure do |config|
    #     config.api_key = ENV["OPENFIGI_API_KEY"]
    #   end
    # @yieldparam config [Configuration]
    # @return [void]
    def configure
      yield configuration
    end
  end
end
