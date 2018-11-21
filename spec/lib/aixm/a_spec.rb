require_relative '../../spec_helper'

describe AIXM::A do
  let :subject_2 do
    AIXM.a('0')
  end

  let :subject_3 do
    AIXM.a(0)
  end

  describe :initialize do
    it "fails on invalid values" do
      -> { AIXM.a('foobar') }.must_raise ArgumentError
    end

    it "parses String as angle with precision=2" do
      AIXM.a('34L').tap do |h|
        h.deg.must_equal 340
        h.precision.must_equal 2
        h.suffix.must_equal :L
      end
    end

    it "parses Numeric as angle with precision=3" do
      AIXM.a(12).tap do |h|
        h.deg.must_equal 12
        h.precision.must_equal 3
        h.suffix.must_be :nil?
      end
    end
  end

  describe :to_s do
    context "precision=2" do
      it "rounds and zero-pad deg to length 2 and concats suffix" do
        AIXM.a('05').to_s.must_equal '05'
        AIXM.a('05').tap { |a| a.suffix = :L }.to_s.must_equal '05L'
        AIXM.a('05').tap { |a| a.deg = 0 }.to_s.must_equal '36'
      end
    end

    context "precition=3" do
      it "rounds and zero-pad deg to length 3" do
        AIXM.a(5).to_s.must_equal '005'
        AIXM.a(5).tap { |a| a.deg = 0 }.to_s.must_equal '000'
      end
    end
  end

  describe :deg= do
    it "fails on invalid values" do
      [:foobar, '1', -1, 361].wont_be_written_to subject_2, :deg
      [:foobar, '1', -1, 361].wont_be_written_to subject_3, :deg
    end

    context "precision=2" do
      it "rounds to 10 degree steps" do
        subject_2.tap { |s| s.deg = 0 }.deg.must_equal 0
        subject_2.tap { |s| s.deg = 5 }.deg.must_equal 10
        subject_2.tap { |s| s.deg = 154 }.deg.must_equal 150
        subject_2.tap { |s| s.deg = 359 }.deg.must_equal 0
        subject_2.tap { |s| s.deg = 360 }.deg.must_equal 0
      end
    end

    context "precision=3" do
      it "accepts 1 degree steps" do
        subject_3.tap { |s| s.deg = 0 }.deg.must_equal 0
        subject_3.tap { |s| s.deg = 5 }.deg.must_equal 5
        subject_3.tap { |s| s.deg = 154 }.deg.must_equal 154
        subject_3.tap { |s| s.deg = 359 }.deg.must_equal 359
        subject_3.tap { |s| s.deg = 360 }.deg.must_equal 0
      end
    end
  end

  describe :suffix= do
    context "precision=2" do
      it "fails on invalid values" do
        [123, 'r'].wont_be_written_to subject_2, :suffix
      end

      it "accepts nil value" do
        [nil].must_be_written_to subject_2, :suffix
      end

      it "symbolizes valid values" do
        subject_2.tap { |s| s.suffix = 'Z' }.suffix.must_equal :Z
      end
    end

    context "precision=3" do
      it "always fails" do
        -> { subject_3.tap { |s| s.suffix = 'Z' } }.must_raise RuntimeError
      end
    end
  end

  describe :invert do
    it "must calculate inverse deg correctly" do
      { 0 => 180, 90 => 270, 179 => 359, 180 => 0, 270 => 90, 359 => 179, 360 => 180 }.each do |from, to|
        AIXM.a(from).invert.deg.must_equal to
      end
    end

    it "must invert left/right suffix" do
      AIXM.a('34L').invert.suffix.must_equal :R
    end

    it "must leave other suffixes untouched" do
      AIXM.a('35X').invert.suffix.must_equal :X
    end
  end

  describe :inverse_of? do
    it "must return true for inverse pairs" do
      AIXM.a('34L').inverse_of?(AIXM.a('16R')).must_equal true
    end

    it "must return false for non-inverse pairs" do
      AIXM.a('34L').inverse_of?(AIXM.a('12L')).must_equal false
    end
  end

  describe :+ do
    context "precision=2" do
      it "adds degrees as Integer" do
        (subject_2 + 14).must_equal AIXM.a('01')
        (subject_2 + 16).must_equal AIXM.a('02')
        (subject_2 + 370).must_equal AIXM.a('01')
        (AIXM.a('05L') + 20).must_equal AIXM.a('07L')
      end

      it "adds another angle" do
        (AIXM.a('10') + AIXM.a('08')).must_equal AIXM.a('18')
      end
    end

    context "precision=3" do
      it "adds degrees as Integer" do
        (subject_3 + 15).must_equal AIXM.a(15)
        (subject_3 + 370).must_equal AIXM.a(10)
      end
    end
  end

  describe :- do
    context "precision=2" do
      it "subtracts degrees as Integer" do
        (subject_2 - 14).must_equal AIXM.a('35')
        (subject_2 - 16).must_equal AIXM.a('34')
        (AIXM.a('05') - 20).must_equal AIXM.a('03')
        (AIXM.a('05L') - 20).must_equal AIXM.a('03L')
      end

      it "subtracts another angle" do
        (AIXM.a('10') - AIXM.a('08')).must_equal AIXM.a('02')
      end
    end

    context "precision=3" do
      it "subtracts degrees as Integer" do
        (subject_3 - 15).must_equal AIXM.a(345)
        (AIXM.a(55) - 20).must_equal AIXM.a(35)
      end
    end
  end

  describe :== do
    it "recognizes angles with identical deg and suffix as equal" do
      AIXM.a('34L').must_equal AIXM.a('34L')
    end

    it "recognizes angles with different deg or suffix as unequal" do
      AIXM.a('34L').wont_equal AIXM.a('35L')
      AIXM.a('34L').wont_equal AIXM.a('34R')
    end

    it "recognizes angles with different precision as unequal" do
      AIXM.a('34').wont_equal AIXM.a(340)
    end

    it "recognizes objects of different class as unequal" do
      subject_2.wont_equal :oggy
    end
  end

  describe :hash do
    it "returns an integer" do
      subject_2.hash.must_be_instance_of Integer
    end

    it "returns different hashes for different precisions" do
      subject_2.hash.wont_equal subject_3.hash
    end

    it "allows for the use of instances as hash keys" do
      dupe = subject_2.dup
      { subject_2 => true }[dupe].must_equal true
    end
  end
end
