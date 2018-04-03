require_relative '../../spec_helper'

describe AIXM::F do
  subject do
    AIXM::Factory.f
  end

  describe :freq= do
    it "fails on invalid values" do
      -> { subject.freq = :foo }.must_raise ArgumentError
    end

    it "converts Numeric to Float" do
      subject.tap { |s| s.freq = 5 }.freq.must_equal 5.0
    end
  end

  describe :unit= do
    it "fails on invalid values" do
      -> { subject.unit = :foo }.must_raise ArgumentError
    end

    it "symbolizes and downcases values" do
      subject.tap { |s| s.unit = "MHz" }.unit.must_equal :mhz
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

end
