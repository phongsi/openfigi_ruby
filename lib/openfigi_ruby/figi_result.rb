# frozen_string_literal: true

module OpenfigiRuby
  # Represents a single instrument returned by the OpenFIGI API.
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
