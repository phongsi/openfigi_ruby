# frozen_string_literal: true

module OpenfigiRuby
  # Holds configuration for the gem. Set values via {OpenfigiRuby.configure}.
  #
  # @!attribute [rw] api_key
  #   @return [String, nil] OpenFIGI API key. Without a key, stricter rate limits apply.
  # @!attribute [rw] open_timeout
  #   @return [Integer] seconds to wait when opening a connection (default: 10)
  # @!attribute [rw] read_timeout
  #   @return [Integer] seconds to wait for a response (default: 30)
  class Configuration
    # OpenFIGI V3 API base URL.
    # @api private
    BASE_URL = "https://api.openfigi.com/v3"

    attr_accessor :api_key, :open_timeout, :read_timeout

    def initialize
      @api_key = nil
      @open_timeout = 10
      @read_timeout = 30
    end
  end
end
