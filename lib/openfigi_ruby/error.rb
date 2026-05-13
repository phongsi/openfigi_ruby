# frozen_string_literal: true

module OpenfigiRuby
  class Error < StandardError; end

  class ApiError < Error
    attr_reader :status_code, :body

    def initialize(message = nil, status_code: nil, body: nil)
      super(message)
      @status_code = status_code
      @body = body
    end
  end

  # Raised on HTTP 401 — invalid or missing API key.
  class AuthenticationError < ApiError; end

  # Raised on HTTP 429 — rate limit exceeded.
  class RateLimitError < ApiError; end

  # Raised on HTTP 400 — malformed request payload.
  class InvalidRequestError < ApiError; end

  # Raised on HTTP 500/503 — transient server errors (retry with backoff).
  class ServerError < ApiError; end
end
