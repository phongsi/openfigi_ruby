# frozen_string_literal: true

module OpenfigiRuby
  # Result for a single job in a bulk mapping request.
  #
  # On success, {data} is an array of {FigiResult} objects and {warning} is nil.
  # When no match is found, {data} is nil and {warning} holds the API message.
  #
  # @!attribute [r] data
  #   @return [Array<FigiResult>, nil] matched instruments, or nil when no match was found
  # @!attribute [r] warning
  #   @return [String, nil] API warning message when no identifier was found
  MappingResult = Struct.new(:data, :warning, keyword_init: true) do
    # Returns true if the job matched at least one instrument.
    # @return [Boolean]
    def found?
      !data.nil? && !data.empty?
    end
  end
end
