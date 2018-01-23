require_relative '../../spec_helper'

describe AIXM::F do
  describe :initialize do
    it "must parse valid unit" do
      subject = AIXM.f(123.35, :MHZ)
      subject.freq.must_equal 123.35
      subject.unit.must_equal :MHZ
    end

    it "won't parse invalid unit" do
      -> { AIXM.f(123.35, :FOO) }.must_raise ArgumentError
    end
  end

  describe :== do
    it "recognizes objects with identical frequency and unit as equal" do
      a = AIXM.f(123.0, :MHZ)
      b = AIXM.f(123, 'MHZ')
      a.must_equal b
    end

    it "recognizes objects with different frequency or unit as unequal" do
      a = AIXM.f(123.35, :MHZ)
      b = AIXM.f(123.35, :KHZ)
      a.wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.f(123.35, :MHZ)
      b = :oggy
      a.wont_equal b
    end
  end

  describe :between? do
    subject do
      AIXM.f(100, :MHZ)
    end

    it "detect frequencies within a frequency band" do
      subject.between?(90, 110, :MHZ).must_equal true
      subject.between?(90, 100, :MHZ).must_equal true
      subject.between?(100.0, 100.1, :MHZ).must_equal true
    end

    it "detect frequencies outside of a frequency band" do
      subject.between?(90, 110, :KHZ).must_equal false
      subject.between?(90, 95, :MHZ).must_equal false
    end
  end
end
