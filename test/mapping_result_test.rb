# frozen_string_literal: true

require "test_helper"

class MappingResultTest < Minitest::Test
  def test_found_with_results
    result = OpenfigiRuby::MappingResult.new(data: [OpenfigiRuby::FigiResult.new])
    assert result.found?
  end

  def test_found_with_empty_data
    result = OpenfigiRuby::MappingResult.new(data: [])
    refute result.found?
  end

  def test_found_with_warning
    result = OpenfigiRuby::MappingResult.new(warning: "No identifier found.")
    refute result.found?
  end
end
