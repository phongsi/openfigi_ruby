# frozen_string_literal: true

module OpenfigiRuby
  # Result for a single job in a bulk mapping request.
  #
  # On success, +data+ is an array of FigiResult objects.
  # When no match is found, +data+ is nil and +warning+ holds a message.
  MappingResult = Struct.new(:data, :warning, keyword_init: true) do
    def found?
      !data.nil? && !data.empty?
    end
  end
end
