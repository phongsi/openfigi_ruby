# frozen_string_literal: true

module OpenfigiRuby
  class Configuration
    BASE_URL = "https://api.openfigi.com/v3"

    attr_accessor :api_key, :open_timeout, :read_timeout

    def initialize
      @api_key = nil
      @open_timeout = 10
      @read_timeout = 30
    end
  end
end
