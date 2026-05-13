# frozen_string_literal: true

module OpenfigiRuby
  # Result from POST /v3/search.
  #
  # @!attribute [r] data
  #   @return [Array<FigiResult>] instruments matching the search query for this page
  # @!attribute [r] next_page
  #   @return [String, nil] opaque pagination token; pass as +start:+ to {Client#search} to fetch
  #     the next page. nil when this is the last page.
  # @!attribute [r] error
  #   @return [String, nil] error message when the query itself is invalid
  SearchResult = Struct.new(:data, :next_page, :error, keyword_init: true)

  # Result from POST /v3/filter.
  #
  # Like {SearchResult} but results are sorted alphabetically by FIGI and a total count is included.
  #
  # @!attribute [r] data
  #   @return [Array<FigiResult>] instruments matching the filter for this page
  # @!attribute [r] next_page
  #   @return [String, nil] opaque pagination token; pass as +start:+ to {Client#filter} to fetch
  #     the next page. nil when this is the last page.
  # @!attribute [r] total
  #   @return [Integer] total number of matching instruments across all pages
  # @!attribute [r] error
  #   @return [String, nil] error message when the request is invalid
  FilterResult = Struct.new(:data, :next_page, :total, :error, keyword_init: true)
end
