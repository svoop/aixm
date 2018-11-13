require_relative '../../spec_helper'

describe AIXM::H do
  subject do
    AIXM::Factory.h
  end

  describe :initialize do
    it "fails on invalid values" do
      -> { AIXM.h('foobar') }.must_raise ArgumentError
    end

    it "parses valid values" do
      AIXM.h('34L').tap do |h|
        h.deg.must_equal 34
        h.suffix.must_equal :L
      end
      AIXM.h(12).tap do |h|
        h.deg.must_equal 12
        h.suffix.must_be :nil?
      end
    end
  end

  describe :to_s do
    it "pads deg with zero and concats suffix" do
      AIXM.h(5).to_s.must_equal '05'
      AIXM.h('5L').to_s.must_equal '05L'
      AIXM.h('16L').to_s.must_equal '16L'
    end
  end

  describe :deg= do
    it "fails on invalid values" do
      [:foobar, '1', 0, 37].wont_be_written_to subject, :deg
    end

    it "accepts valid values" do
      (1..36).to_a.must_be_written_to subject, :deg
    end
  end

  describe :suffix= do
    it "fails on invalid values" do
      [123, 'r'].wont_be_written_to subject, :suffix
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :suffix
    end

    it "symbolizes valid values" do
      subject.tap { |s| s.suffix = 'Z' }.suffix.must_equal :Z
    end
  end

  describe :== do
    it "recognizes objects with identical deg and suffix as equal" do
      AIXM.h('34L').must_equal AIXM.h('34L')
    end

    it "recognizes objects with different deg or suffix as unequal" do
      AIXM.h('34L').wont_equal AIXM.h('35L')
      AIXM.h('34L').wont_equal AIXM.h('34R')
    end

    it "recognizes objects of different class as unequal" do
      subject.wont_equal :oggy
    end
  end

  describe :invert do
    it "must calculate inverse deg correctly" do
      {
        1 => 19, 2 => 20, 3 => 21, 4 => 22, 5 => 23, 6 => 24, 7 => 25, 8 => 26, 9 => 27,
        10 => 28, 11 => 29, 12 => 30, 13 => 31, 14 => 32, 15 => 33, 16 => 34, 17 => 35, 18 => 36,
        19 => 1, 20 => 2, 21 => 3, 22 => 4, 23 => 5, 24 => 6, 25 => 7, 26 => 8, 27 => 9,
        28 => 10, 29 => 11, 30 => 12, 31 => 13, 32 => 14, 33 => 15, 34 => 16, 35 => 17, 36 => 18
      }.each do |from, to|
        AIXM.h(from).invert.deg.must_equal to
      end
    end

    it "must invert left/right suffix" do
      AIXM.h('34L').invert.suffix.must_equal :R
    end

    it "must leave other suffixes untouched" do
      AIXM.h('35X').invert.suffix.must_equal :X
    end
  end

  describe :inverse_of? do
    it "must return true for inverse pairs" do
      AIXM.h('34L').inverse_of?(AIXM.h('16R')).must_equal true
    end

    it "must return false for non-inverse pairs" do
      AIXM.h('34L').inverse_of?(AIXM.h('12L')).must_equal false
    end
  end
end
