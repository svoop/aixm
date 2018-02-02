require_relative '../../../spec_helper'

describe AIXM::Component::Runway do
  describe :initialize do
    subject do
      AIXM::Component::Runway
    end

    let :airport do
      AIXM::Factory.airport
    end

    it "fails on invalid arguments" do
      -> { subject.new(airport: 0, name: '16L/34R') }.must_raise ArgumentError
      -> { subject.new(airport: airport, name: 0) }.must_raise ArgumentError
    end

    it "upcases and transcodes name" do
      subject.new(airport: airport, name: '16l/34r').name.must_equal '16L/34R'
    end

    it "presets forth and back names" do
      subject.new(airport: airport, name: '16l/34r').forth.name.must_equal '16L'
      subject.new(airport: airport, name: '16l/34r').back.name.must_equal '34R'
      subject.new(airport: airport, name: '16l').forth.name.must_equal '16L'
      subject.new(airport: airport, name: '16l').back.must_be_nil
    end
  end

  subject do
    AIXM::Factory.runway
  end

  describe :length= do
    it "fails on invalid values" do
      -> { subject.length = nil }.must_raise ArgumentError
      -> { subject.length = -1 }.must_raise ArgumentError
    end

    it "normalizes value" do
      subject.tap { |s| s.length = 1234.0 }.length.must_equal 1234
    end
  end

  describe :width= do
    it "fails on invalid values" do
      -> { subject.width = nil }.must_raise ArgumentError
      -> { subject.width = -1 }.must_raise ArgumentError
    end

    it "normalizes value" do
      subject.tap { |s| s.length = 123.0 }.length.must_equal 123
    end
  end

  describe :composition= do
    it "fails on invalid values" do
      -> { subject.composition = nil }.must_raise ArgumentError
      -> { subject.composition = 'foobar' }.must_raise ArgumentError
    end

    it "normalizes values" do
      subject.tap { |s| s.composition = 'CONC' }.composition.must_equal :concrete
    end
  end

  describe :remarks= do
    it "stringifies value unless nil" do
      subject.tap { |s| s.remarks = 'foobar' }.remarks.must_equal 'foobar'
      subject.tap { |s| s.remarks = 123 }.remarks.must_equal '123'
      subject.tap { |s| s.remarks = nil }.remarks.must_be_nil
    end
  end
end

describe AIXM::Component::Runway::Direction do
  describe :initialize do
    subject do
      AIXM::Component::Runway::Direction
    end

    it "fails on invalid arguments" do
      -> { subject.new(runway: 0, name: '16L') }.must_raise ArgumentError
      -> { subject.new(runway: AIXM::Factory.runway, name: 0) }.must_raise ArgumentError
    end

    it "upcases and transcodes name" do
      subject.new(runway: AIXM::Factory.runway, name: '16l').name.must_equal '16L'
    end
  end

  subject do
    AIXM::Component::Runway::Direction.new(runway: AIXM::Factory.runway, name: '16l')
  end

  describe :name= do
    it "overwrites preset name" do
      subject.name.must_equal '16L'
      subject.name = 'x01x'
      subject.name.must_equal 'X01X'
    end
  end

  describe :geographic_orientation= do
    it "fails on out of bound values" do
      -> { subject.geographic_orientation = -1 }.must_raise ArgumentError
      -> { subject.geographic_orientation = 360 }.must_raise ArgumentError
    end
  end

  describe :xy= do
    it "fails on non AIXM::XY value" do
      -> { subject.xy = nil }.must_raise ArgumentError
    end
  end

  describe :displaced_threshold= do
    it "fails on non AIXM::XY or Numeric value" do
      -> { subject.xy = nil }.must_raise ArgumentError
    end

    it "normalizes value" do
      subject.tap { |s| s.displaced_threshold = 222.0 }.displaced_threshold.must_equal 222
    end

    it "converts coordinates to distance" do
      subject.xy = AIXM.xy(lat: %q(43°59'54.71"N), long: %q(004°45'28.35"E))
      subject.displaced_threshold = AIXM.xy(lat: %q(43°59'48.47"N), long: %q(004°45'30.62"E))
      subject.displaced_threshold.must_equal 199
    end
  end

  describe :magnetic_orientation do
    it "is calculated correctly" do
      subject.geographic_orientation = 16
      subject.magnetic_orientation.must_equal 17
    end
  end
end
