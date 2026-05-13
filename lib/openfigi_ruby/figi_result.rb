# frozen_string_literal: true

module OpenfigiRuby
  # Represents a single financial instrument returned by the OpenFIGI API.
  #
  # @!attribute [r] figi
  #   @return [String] the Financial Instrument Global Identifier (FIGI)
  # @!attribute [r] security_type
  #   @return [String, nil] primary security classification (e.g. "Common Stock", "ETP")
  # @!attribute [r] market_sector
  #   @return [String, nil] market sector (e.g. "Equity", "Corp", "Govt")
  # @!attribute [r] ticker
  #   @return [String, nil] exchange ticker symbol
  # @!attribute [r] name
  #   @return [String, nil] instrument name
  # @!attribute [r] exch_code
  #   @return [String, nil] exchange code (e.g. "US", "LN")
  # @!attribute [r] share_class_figi
  #   @return [String, nil] share class-level FIGI
  # @!attribute [r] composite_figi
  #   @return [String, nil] composite FIGI (aggregates listings across exchanges)
  # @!attribute [r] security_type2
  #   @return [String, nil] secondary security classification
  # @!attribute [r] security_description
  #   @return [String, nil] short description of the security
  # @!attribute [r] metadata
  #   @return [String, nil] optional metadata string returned by the API
  FigiResult = Struct.new(
    :figi,
    :security_type,
    :market_sector,
    :ticker,
    :name,
    :exch_code,
    :share_class_figi,
    :composite_figi,
    :security_type2,
    :security_description,
    :metadata,
    keyword_init: true
  )
end
