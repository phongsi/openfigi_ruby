# frozen_string_literal: true

require "test_helper"

class ClientTest < Minitest::Test
  BASE_URL = "https://api.openfigi.com/v3"

  def setup
    @client = OpenfigiRuby::Client.new(api_key: "test_key")
  end

  # --- mapping ---

  def test_mapping_returns_figi_results
    stub_post("/mapping", [{ "data" => [FIGI_RESULT_JSON] }])

    results = @client.mapping([{ id_type: "TICKER", id_value: "AAPL", exch_code: "US" }])

    assert_equal 1, results.size
    assert results.first.found?
    figi = results.first.data.first
    assert_equal "BBG000B9XRY4", figi.figi
    assert_equal "APPLE INC", figi.name
    assert_equal "AAPL", figi.ticker
    assert_equal "US", figi.exch_code
    assert_equal "Common Stock", figi.security_type
    assert_equal "Equity", figi.market_sector
    assert_equal "BBG001S5N8V8", figi.share_class_figi
    assert_equal "BBG000B9XRY4", figi.composite_figi
  end

  def test_mapping_serializes_snake_case_keys_to_camel_case
    stub = stub_request(:post, "#{BASE_URL}/mapping")
      .with(body: [{ "idType" => "ID_ISIN", "idValue" => "US0378331005", "exchCode" => "US" }].to_json)
      .to_return(status: 200, body: [{ "data" => [FIGI_RESULT_JSON] }].to_json)

    @client.mapping([{ id_type: "ID_ISIN", id_value: "US0378331005", exch_code: "US" }])

    assert_requested stub
  end

  def test_mapping_omits_nil_values
    stub = stub_request(:post, "#{BASE_URL}/mapping")
      .with(body: [{ "idType" => "TICKER", "idValue" => "AAPL" }].to_json)
      .to_return(status: 200, body: [{ "data" => [FIGI_RESULT_JSON] }].to_json)

    @client.mapping([{ id_type: "TICKER", id_value: "AAPL", exch_code: nil }])

    assert_requested stub
  end

  def test_mapping_returns_warning_when_no_match
    stub_post("/mapping", [{ "warning" => "No identifier found." }])

    results = @client.mapping([{ id_type: "TICKER", id_value: "UNKNOWN" }])

    refute results.first.found?
    assert_equal "No identifier found.", results.first.warning
  end

  def test_mapping_handles_multiple_jobs
    stub_post("/mapping", [
      { "data" => [FIGI_RESULT_JSON] },
      { "warning" => "No identifier found." }
    ])

    results = @client.mapping([
      { id_type: "TICKER", id_value: "AAPL" },
      { id_type: "TICKER", id_value: "UNKNOWN" }
    ])

    assert_equal 2, results.size
    assert results[0].found?
    refute results[1].found?
  end

  def test_mapping_sends_api_key_header
    stub = stub_request(:post, "#{BASE_URL}/mapping")
      .with(headers: { "X-OPENFIGI-APIKEY" => "test_key" })
      .to_return(status: 200, body: [{ "data" => [FIGI_RESULT_JSON] }].to_json)

    @client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])

    assert_requested stub
  end

  def test_mapping_without_api_key_omits_header
    client = OpenfigiRuby::Client.new(api_key: nil)
    stub = stub_request(:post, "#{BASE_URL}/mapping")
      .to_return(status: 200, body: [{ "data" => [FIGI_RESULT_JSON] }].to_json)

    client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])

    assert_not_requested stub.with(headers: { "X-OPENFIGI-APIKEY" => /.*/ })
  end

  # --- mapping_values ---

  def test_mapping_values_with_symbol
    stub_get("/mapping/values/idType", { "values" => ["ID_ISIN", "ID_CUSIP", "TICKER"] })

    values = @client.mapping_values(:id_type)

    assert_equal ["ID_ISIN", "ID_CUSIP", "TICKER"], values
  end

  def test_mapping_values_with_camel_case_string
    stub_get("/mapping/values/exchCode", { "values" => ["US", "LN"] })

    values = @client.mapping_values("exchCode")

    assert_equal ["US", "LN"], values
  end

  # --- search ---

  def test_search_returns_results
    stub_post("/search", { "data" => [FIGI_RESULT_JSON], "next" => "BBG_TOKEN" })

    result = @client.search(query: "Apple")

    assert_equal 1, result.data.size
    assert_equal "BBG000B9XRY4", result.data.first.figi
    assert_equal "BBG_TOKEN", result.next_page
    assert_nil result.error
  end

  def test_search_sends_query_and_filters
    stub = stub_request(:post, "#{BASE_URL}/search")
      .with(body: { "query" => "Apple", "exchCode" => "US" }.to_json)
      .to_return(status: 200, body: { "data" => [] }.to_json)

    @client.search(query: "Apple", exch_code: "US")

    assert_requested stub
  end

  def test_search_sends_pagination_token
    stub = stub_request(:post, "#{BASE_URL}/search")
      .with(body: { "query" => "Apple", "start" => "BBG_TOKEN" }.to_json)
      .to_return(status: 200, body: { "data" => [] }.to_json)

    @client.search(query: "Apple", start: "BBG_TOKEN")

    assert_requested stub
  end

  def test_search_nil_next_page_on_last_page
    stub_post("/search", { "data" => [FIGI_RESULT_JSON] })

    result = @client.search(query: "Apple")

    assert_nil result.next_page
  end

  # --- filter ---

  def test_filter_returns_results_with_total
    stub_post("/filter", { "data" => [FIGI_RESULT_JSON], "total" => 42, "next" => nil })

    result = @client.filter(query: "Apple")

    assert_equal 1, result.data.size
    assert_equal 42, result.total
    assert_nil result.next_page
  end

  def test_filter_without_query
    stub = stub_request(:post, "#{BASE_URL}/filter")
      .with(body: { "currency" => "USD" }.to_json)
      .to_return(status: 200, body: { "data" => [], "total" => 0 }.to_json)

    @client.filter(currency: "USD")

    assert_requested stub
  end

  # --- error handling ---

  def test_raises_authentication_error_on_401
    stub_request(:post, "#{BASE_URL}/mapping").to_return(status: 401, body: "Unauthorized")

    error = assert_raises(OpenfigiRuby::AuthenticationError) do
      @client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])
    end
    assert_equal 401, error.status_code
  end

  def test_raises_rate_limit_error_on_429
    stub_request(:post, "#{BASE_URL}/mapping").to_return(status: 429, body: "Too Many Requests")

    error = assert_raises(OpenfigiRuby::RateLimitError) do
      @client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])
    end
    assert_equal 429, error.status_code
  end

  def test_raises_invalid_request_error_on_400
    stub_request(:post, "#{BASE_URL}/mapping").to_return(status: 400, body: "Bad Request")

    error = assert_raises(OpenfigiRuby::InvalidRequestError) do
      @client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])
    end
    assert_equal 400, error.status_code
  end

  def test_raises_server_error_on_500
    stub_request(:post, "#{BASE_URL}/mapping").to_return(status: 500, body: "Internal Server Error")

    error = assert_raises(OpenfigiRuby::ServerError) do
      @client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])
    end
    assert_equal 500, error.status_code
  end

  def test_raises_server_error_on_503
    stub_request(:post, "#{BASE_URL}/mapping").to_return(status: 503, body: "Service Unavailable")

    assert_raises(OpenfigiRuby::ServerError) do
      @client.mapping([{ id_type: "TICKER", id_value: "AAPL" }])
    end
  end

  def test_all_errors_are_subclasses_of_api_error
    [
      OpenfigiRuby::AuthenticationError,
      OpenfigiRuby::RateLimitError,
      OpenfigiRuby::InvalidRequestError,
      OpenfigiRuby::ServerError
    ].each do |klass|
      assert klass < OpenfigiRuby::ApiError
    end
  end

  private

  def stub_post(path, response_body)
    stub_request(:post, "#{BASE_URL}#{path}")
      .to_return(status: 200, body: response_body.to_json, headers: { "Content-Type" => "application/json" })
  end

  def stub_get(path, response_body)
    stub_request(:get, "#{BASE_URL}#{path}")
      .to_return(status: 200, body: response_body.to_json, headers: { "Content-Type" => "application/json" })
  end
end
