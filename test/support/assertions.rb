require 'minitest/mock'

module Assertions
  def assert_not(object, message = nil)
    message ||= "Expected #{object} to be nil or false"
    assert !object, message
  end

  def freeze_time(&block)
    if block
      reference_date = Time.now

      Time.stub :now, reference_date do
        block.call
      end
    else
      block.call
    end
  end
end
