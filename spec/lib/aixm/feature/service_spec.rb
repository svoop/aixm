require_relative '../../../spec_helper'

describe AIXM::Feature::Service do
  subject do
    AIXM::Factory.service
  end

  describe :initialize do
    it "sets defaults" do
      subject = AIXM::Feature::Service.new(
        type: :approach_control_service
      )
      _(subject.frequencies).must_equal []
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _{ subject.type = :foobar }.must_raise ArgumentError
      _{ subject.type = nil }.must_raise ArgumentError
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.type = :area_control_service }.type).must_equal :area_control_service
      _(subject.tap { |s| s.type = :ATIS }.type).must_equal :automated_terminal_information_service
    end
  end

  describe :timetable= do
    macro :timetable
  end

  describe :remarks= do
    macro :remarks
  end

  describe :add_frequency do
    it "fails on invalid arguments" do
      _{ subject.add_frequency nil }.must_raise ArgumentError
    end

    it "adds frequency to the array" do
      count = subject.frequencies.count
      subject.add_frequency(AIXM::Factory.frequency)
      _(subject.frequencies.count).must_equal count + 1
    end
  end

  describe :guess_unit_type do
    it "finds the probably unit type for a matchable service" do
      _(subject.tap { |s| s.type = :flight_information_service }.guessed_unit_type).must_equal :flight_information_centre
    end

    it "returns nil for an unmatchable service" do
      _(subject.tap { |s| s.type = :aeronautical_mobile_satellite_service }.guessed_unit_type).must_be_nil
    end
  end

end
