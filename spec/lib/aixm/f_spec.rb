require_relative '../../spec_helper'

describe AIXM::F do
  subject do
    AIXM::Factory.f
  end

  describe :freq= do
    it "fails on invalid values" do
      [:foobar].wont_be_written_to subject, :freq
    end

    it "converts Numeric to Float" do
      subject.tap { |s| s.freq = 5 }.freq.must_equal 5.0
    end
  end

  describe :unit= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :unit
    end

    it "symbolizes and downcases values" do
      subject.tap { |s| s.unit = "MHz" }.unit.must_equal :mhz
    end
  end

  describe :between? do
    subject do
      AIXM.f(100, :mhz)
    end

    it "detect frequencies within a frequency band" do
      subject.between?(90, 110, :mhz).must_equal true
      subject.between?(90, 100, :mhz).must_equal true
      subject.between?(100.0, 100.1, :mhz).must_equal true
    end

    it "detect frequencies outside of a frequency band" do
      subject.between?(90, 110, :khz).must_equal false
      subject.between?(90, 95, :mhz).must_equal false
    end
  end

  describe :== do
    it "recognizes objects with identical frequency and unit as equal" do
      a = AIXM.f(123.0, :mhz)
      b = AIXM.f(123, 'MHZ')
      a.must_equal b
    end

    it "recognizes objects with different frequency or unit as unequal" do
      a = AIXM.f(123.35, :mhz)
      b = AIXM.f(123.35, :khz)
      a.wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.f(123.35, :mhz)
      b = :oggy
      a.wont_equal b
    end
  end

  describe :hash do
    it "returns an integer" do
      subject.hash.must_be_instance_of Integer
    end

    it "allows for the use of instances as hash keys" do
      dupe = subject.dup
      { subject => true }[dupe].must_equal true
    end
  end

  describe :zero? do
    it "returns true for zero frequency" do
      subject.tap { |s| s.freq = 0 }.must_be :zero?
    end

    it "returns false for non-zero frequency" do
      subject.tap { |s| s.freq = 1 }.wont_be :zero?
    end
  end
end
