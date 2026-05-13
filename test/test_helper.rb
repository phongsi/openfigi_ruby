# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"
require "openfigi_ruby"

FIGI_RESULT_JSON = {
  "figi" => "BBG000B9XRY4",
  "securityType" => "Common Stock",
  "marketSector" => "Equity",
  "ticker" => "AAPL",
  "name" => "APPLE INC",
  "exchCode" => "US",
  "shareClassFIGI" => "BBG001S5N8V8",
  "compositeFIGI" => "BBG000B9XRY4",
  "securityType2" => "Common Stock",
  "securityDescription" => "AAPL",
  "metadata" => nil
}.freeze
