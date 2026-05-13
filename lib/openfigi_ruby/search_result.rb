# frozen_string_literal: true

module OpenfigiRuby
  # Result from POST /v3/search.
  #
  # +data+      - array of FigiResult objects for this page
  # +next_page+ - opaque pagination token; pass as +start:+ to fetch the next page (nil on last page)
  # +error+     - error message string when the query itself is invalid
  SearchResult = Struct.new(:data, :next_page, :error, keyword_init: true)

  # Result from POST /v3/filter.
  #
  # Same as SearchResult with an additional +total+ count of all matching instruments.
  FilterResult = Struct.new(:data, :next_page, :total, :error, keyword_init: true)
end
