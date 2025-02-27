# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'red_amber'

require 'pathname'
require 'tempfile'
require 'timeout'
require 'webrick'
require 'zlib'

require 'test-unit'

module Helper
  def entity_path
    (Pathname.new(__dir__) / 'entity').expand_path
  end

  def assert_equal_array(expected, actual, message = nil)
    assert_equal(Array(expected), Array(actual), message)
  end

  def assert_equal_array_in_delta(expected, actual, delta = 0.001, message = '')
    Array(expected).zip(Array(actual)) do |e, a|
      assert_in_delta(e, a, delta, message)
    end
  end

  def assert_equal_array_with_nan(expected, actual, delta = 1e-15, message = nil)
    Array(expected).zip(Array(actual)) do |e, a|
      if e.nil? || e.nan? || e.infinite?
        assert_equal(e.to_s, a.to_s, message)
      else
        assert_in_delta(e, a, delta, message)
      end
    end
  end
end
