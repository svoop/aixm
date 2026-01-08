gem 'minitest'

require 'debug'
require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'aixm')

require 'minitest/flash'

require Pathname(__dir__).join('factory')

Minitest.load_plugins

module AIXM
  def self.root
    Pathname(__dir__).join('..')
  end
end

class Minitest::Spec
  class << self
    alias_method :context, :describe

    def macro(name)
      load Pathname(__dir__).join("macros/#{name}.rb")
    end
  end
end

module Minitest::Assertions
  def assert_write(values, subject, attribute, msg=nil)
    values.each do |value|
      msg = message(msg) { "Expected #{mu_pp(value)} to be written to #{subject.class}##{attribute}" }
      subject.send("#{attribute}=", value)
      assert(subject.send(attribute) == value, msg)
    end
  end

  def refute_write(values, subject, attribute, msg=nil)
    values.each do |value|
      msg = "Expected #{mu_pp(value)} to raise ArgumentError when written to #{subject.class}##{attribute}"
      assert_raises(ArgumentError, msg) { subject.send("#{attribute}=", value) }
    end
  end
end

module Minitest::Expectations
  infect_an_assertion :assert_write, :must_be_written_to, :reverse
  infect_an_assertion :refute_write, :wont_be_written_to, :reverse
end

class Minitest::Spec
  before :each do
    AIXM.config.schema = :aixm
    AIXM.config.voice_channel_separation = :any
    AIXM.config.mid = false
  end
end
