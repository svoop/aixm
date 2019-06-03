$VERBOSE = nil   # silence warnings

gem 'minitest'

require 'pathname'

require 'minitest/autorun'
require Pathname(__dir__).join('..', 'lib', 'aixm')

require 'minitest/sound'
require 'minitest/sound/reporter'
Minitest::Sound.success = Pathname(__dir__).join('sounds/success.mp3').to_s
Minitest::Sound.failure = Pathname(__dir__).join('sounds/failure.mp3').to_s
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new, Minitest::Sound::Reporter.new]

require 'minitest/focus'
require 'minitest/matchers'
require Pathname(__dir__).join('factory')

module AIXM
  def self.root
    Pathname(__dir__).join('..')
  end
end

class MiniTest::Spec
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

Array.infect_an_assertion :assert_write, :must_be_written_to, :reverse
Array.infect_an_assertion :refute_write, :wont_be_written_to, :reverse
