# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module OpenfigiRuby
  class Client
    # Valid keys for {#mapping_values}.
    MAPPING_VALUE_KEYS = %w[idType exchCode micCode currency marketSecDes securityType securityType2].freeze

    # @param api_key [String, nil] overrides the globally configured key
    # @param open_timeout [Integer] seconds before the connection times out
    # @param read_timeout [Integer] seconds before the read times out
    def initialize(
      api_key: OpenfigiRuby.configuration.api_key,
      open_timeout: OpenfigiRuby.configuration.open_timeout,
      read_timeout: OpenfigiRuby.configuration.read_timeout
    )
      @api_key = api_key
      @open_timeout = open_timeout
      @read_timeout = read_timeout
    end

    # Maps third-party identifiers to FIGIs (POST /v3/mapping).
    #
    # @param jobs [Array<Hash>] each hash must include +:id_type+ and +:id_value+.
    #   Optional keys: +:exch_code+, +:mic_code+, +:currency+, +:market_sec_des+,
    #   +:security_type+, +:security_type2+, +:include_unlisted_equities+,
    #   +:option_type+, +:strike+, +:contract_size+, +:coupon+,
    #   +:expiration+, +:maturity+, +:state_code+.
    # @return [Array<MappingResult>] one result per input job
    #
    # @example
    #   client.mapping([
    #     { id_type: "ID_ISIN", id_value: "US4592001014" },
    #     { id_type: "TICKER", id_value: "AAPL", exch_code: "US" }
    #   ])
    def mapping(jobs)
      body = jobs.map { |job| serialize(job) }
      response = post("/mapping", body)
      response.map { |item| parse_mapping_result(item) }
    end

    # Returns the set of valid values for a filterable field (GET /v3/mapping/values/:key).
    #
    # @param key [String, Symbol] snake_case or camelCase field name.
    #   Valid values: :id_type, :exch_code, :mic_code, :currency,
    #   :market_sec_des, :security_type, :security_type2
    # @return [Array<String>]
    #
    # @example
    #   client.mapping_values(:id_type)
    def mapping_values(key)
      api_key = camelize(key.to_s)
      response = get("/mapping/values/#{api_key}")
      response["values"]
    end

    # Searches for FIGIs by keyword (POST /v3/search).
    #
    # @param query [String] search terms
    # @param start [String, nil] pagination token from a previous {SearchResult#next_page}
    # @param filters [Hash] optional snake_case filter keys (same as mapping job filters)
    # @return [SearchResult]
    #
    # @example
    #   result = client.search(query: "Apple", exch_code: "US")
    #   result.data   #=> [#<struct OpenfigiRuby::FigiResult ...>, ...]
    #   result.next_page  #=> "BBG..." or nil
    def search(query:, start: nil, **filters)
      body = { "query" => query }
      body["start"] = start if start
      body.merge!(serialize(filters))
      response = post("/search", body)
      parse_search_result(response)
    end

    # Filters FIGIs with alphabetical ordering and a total count (POST /v3/filter).
    #
    # @param query [String, nil] optional search terms
    # @param start [String, nil] pagination token from a previous {FilterResult#next_page}
    # @param filters [Hash] optional snake_case filter keys
    # @return [FilterResult]
    def filter(query: nil, start: nil, **filters)
      body = {}
      body["query"] = query if query
      body["start"] = start if start
      body.merge!(serialize(filters))
      response = post("/filter", body)
      parse_filter_result(response)
    end

    private

    BASE_URL = "https://api.openfigi.com/v3"

    def post(path, body)
      uri = URI("#{BASE_URL}#{path}")
      http = build_http(uri)
      request = Net::HTTP::Post.new(uri)
      apply_headers(request)
      request.body = body.to_json
      handle_response(http.request(request))
    end

    def get(path)
      uri = URI("#{BASE_URL}#{path}")
      http = build_http(uri)
      request = Net::HTTP::Get.new(uri)
      apply_headers(request)
      handle_response(http.request(request))
    end

    def build_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout
      http
    end

    def apply_headers(request)
      request["Content-Type"] = "application/json"
      request["X-OPENFIGI-APIKEY"] = @api_key if @api_key
    end

    def handle_response(response)
      body = response.body
      code = response.code.to_i

      case code
      when 200
        JSON.parse(body)
      when 400
        raise InvalidRequestError.new("Invalid request payload", status_code: code, body: body)
      when 401
        raise AuthenticationError.new("Invalid API key", status_code: code, body: body)
      when 429
        raise RateLimitError.new("Rate limit exceeded", status_code: code, body: body)
      when 500, 503
        raise ServerError.new("Server error (#{code})", status_code: code, body: body)
      else
        raise ApiError.new("Unexpected response (#{code})", status_code: code, body: body)
      end
    end

    # Converts a hash with snake_case symbol keys to camelCase string keys,
    # dropping any nil values.
    def serialize(hash)
      hash.each_with_object({}) do |(key, value), result|
        next if value.nil?

        result[camelize(key.to_s)] = value
      end
    end

    # "id_type" => "idType", "security_type2" => "securityType2"
    def camelize(snake_str)
      parts = snake_str.split("_")
      parts[0] + parts[1..].map(&:capitalize).join
    end

    def parse_mapping_result(item)
      if item.key?("data")
        MappingResult.new(data: item["data"].map { |r| build_figi_result(r) })
      else
        MappingResult.new(warning: item["warning"])
      end
    end

    def parse_search_result(response)
      SearchResult.new(
        data: Array(response["data"]).map { |r| build_figi_result(r) },
        next_page: response["next"],
        error: response["error"]
      )
    end

    def parse_filter_result(response)
      FilterResult.new(
        data: Array(response["data"]).map { |r| build_figi_result(r) },
        next_page: response["next"],
        total: response["total"],
        error: response["error"]
      )
    end

    def build_figi_result(hash)
      FigiResult.new(
        figi: hash["figi"],
        security_type: hash["securityType"],
        market_sector: hash["marketSector"],
        ticker: hash["ticker"],
        name: hash["name"],
        exch_code: hash["exchCode"],
        share_class_figi: hash["shareClassFIGI"],
        composite_figi: hash["compositeFIGI"],
        security_type2: hash["securityType2"],
        security_description: hash["securityDescription"],
        metadata: hash["metadata"]
      )
    end
  end
end
