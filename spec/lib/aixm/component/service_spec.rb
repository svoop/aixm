require_relative '../../../spec_helper'

describe AIXM::Component::Service do
  subject do
    AIXM::Factory.service
  end

  describe :initialize do
    it "sets defaults" do
      subject = AIXM::Component::Service.new(
        name: "PUJAUT TOWER",
        type: :approach_control_service
      )
      subject.frequencies.must_equal []
    end
  end

  describe :name= do
    it "fails on invalid values" do
      -> { subject.name = :foobar }.must_raise ArgumentError
      -> { subject.name = nil }.must_raise ArgumentError
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'Nîmes-Alès' }.name.must_equal 'NIMES-ALES'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.type = :area_control_service }.type.must_equal :area_control_service
      subject.tap { |s| s.type = :ATIS }.type.must_equal :automated_terminal_information_service
    end
  end

  describe :schedule= do
    macro :schedule
  end

  describe :remarks= do
    macro :remarks
  end

  describe :add_frequency do
    it "fails on invalid arguments" do
      -> { subject.add_frequency nil }.must_raise ArgumentError
    end

    it "adds frequency to the array" do
      count = subject.frequencies.count
      subject.add_frequency(AIXM::Factory.frequency)
      subject.frequencies.count.must_equal count + 1
    end
  end

end
