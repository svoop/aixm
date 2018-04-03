require_relative '../../../spec_helper'

describe AIXM::Component::Runway do
  subject do
    AIXM::Factory.airport.runways.first
  end

  describe :initialize do
    it "sets defaults for bidirectional runways" do
      subject.forth.name.must_equal '16L'
      subject.back.name.must_equal '34R'
    end

    it "sets defaults for unidirectional runways" do
      subject = AIXM::Component::Runway.new(name: '30')
      subject.forth.name.must_equal '30'
      subject.back.must_be :nil?
    end
  end

  describe :name= do
    it "upcases and transcodes value" do
      subject.tap { |s| s.name = '10r/28l' }.name.must_equal '10R/28L'
    end
  end

  describe :length= do
    it "fails on invalid values" do
      -> { subject.length = :foobar }.must_raise ArgumentError
      -> { subject.length = nil }.must_raise ArgumentError
      -> { subject.length = -1 }.must_raise ArgumentError
    end

    it "converts valid values to integer" do
      subject.tap { |s| s.length = 1000.5 }.length.must_equal 1000
    end
  end

  describe :width= do
    it "fails on invalid values" do
      -> { subject.width = :foobar }.must_raise ArgumentError
      -> { subject.width = nil }.must_raise ArgumentError
      -> { subject.width = -1 }.must_raise ArgumentError
    end

    it "converts valid values to integer" do
      subject.tap { |s| s.width = 150.5 }.width.must_equal 150
    end
  end

  describe :composition= do
    it "fails on invalid values" do
      -> { subject.composition = :foobar }.must_raise ArgumentError
      -> { subject.composition = nil }.must_raise ArgumentError
    end

    it "normalizes valid values" do
      subject.tap { |s| s.composition = :macadam }.composition.must_equal :macadam
      subject.tap { |s| s.composition = :GRADE }.composition.must_equal :graded_earth
    end
  end

  describe :remarks= do
    macro :remarks
  end
end

describe AIXM::Component::Runway::Direction do
  subject do
    AIXM::Factory.airport.runways.first.forth
  end

  describe :name= do
    it "overwrites preset name" do
      subject.name.must_equal '16L'
      subject.name = 'x01x'
      subject.name.must_equal 'X01X'
    end
  end

  describe :geographic_orientation= do
    it "fails on invalid values" do
      -> { subject.geographic_orientation = :foobar }.must_raise ArgumentError
      -> { subject.geographic_orientation = -1 }.must_raise ArgumentError
      -> { subject.geographic_orientation = 360 }.must_raise ArgumentError
    end

    it "converts valid values to integer" do
      subject.tap { |s| s.geographic_orientation = 100.5 }.geographic_orientation.must_equal 100
    end
  end

  describe :xy= do
    macro :xy
  end

  describe :z= do
    macro :z_qnh
  end

  describe :displaced_threshold= do
    it "fails on invalid values" do
      -> { subject.displaced_threshold = nil }.must_raise ArgumentError
    end

    it "converts valid values to integer" do
      subject.tap { |s| s.displaced_threshold = 222.0 }.displaced_threshold.must_equal 222
    end

    it "converts coordinates to distance" do
      subject.xy = AIXM.xy(lat: %q(43°59'54.71"N), long: %q(004°45'28.35"E))
      subject.displaced_threshold = AIXM.xy(lat: %q(43°59'48.47"N), long: %q(004°45'30.62"E))
      subject.displaced_threshold.must_equal 199
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :magnetic_orientation do
    it "is calculated correctly" do
      subject.geographic_orientation = 16
      subject.magnetic_orientation.must_equal 17
    end
  end
end
