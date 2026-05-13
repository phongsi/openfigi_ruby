# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @config = OpenfigiRuby::Configuration.new
  end

  def test_defaults
    assert_nil @config.api_key
    assert_equal 10, @config.open_timeout
    assert_equal 30, @config.read_timeout
  end

  def test_configure_block
    OpenfigiRuby.configure do |c|
      c.api_key = "test_key"
      c.open_timeout = 5
      c.read_timeout = 15
    end

    assert_equal "test_key", OpenfigiRuby.configuration.api_key
    assert_equal 5, OpenfigiRuby.configuration.open_timeout
    assert_equal 15, OpenfigiRuby.configuration.read_timeout
  ensure
    OpenfigiRuby.instance_variable_set(:@configuration, nil)
  end
end
