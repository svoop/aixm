require_relative '../../spec_helper'

describe AIXM::F do
  describe :initialize do
    it "must parse valid unit" do
      subject = AIXM.f(123.35, :mhz)
      subject.freq.must_equal 123.35
      subject.unit.must_equal :mhz
    end

    it "won't parse invalid unit" do
      -> { AIXM.f(123.35, :foo) }.must_raise ArgumentError
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
