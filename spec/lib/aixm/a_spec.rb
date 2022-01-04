require_relative '../../spec_helper'

describe AIXM::A do
  subject do
    AIXM.a(0)
  end

  describe :initialize do
    it "fails on invalid values" do
      _{ AIXM.a('foobar') }.must_raise ArgumentError
    end

    context String do
      it "accepts angle with suffix" do
        AIXM.a('34L').tap do |angle|
          _(angle.deg).must_equal 340
          _(angle.suffix).must_equal :L
        end
      end

      it "accepts angle without suffix" do
        AIXM.a('16').tap do |angle|
          _(angle.deg).must_equal 160
          _(angle.suffix).must_be :nil?
        end
      end

      it "fails on invalid values" do
        ['00', '37', '123R', '12r'].each do |value|
          _{ AIXM.a(value) }.must_raise ArgumentError
        end
      end
    end

    context Numeric do
      it "accepts positive angle" do
        AIXM.a(12).tap do |angle|
          _(angle.deg).must_equal 12
          _(angle.suffix).must_be :nil?
        end
      end

      it "accepts negative angle" do
        AIXM.a(-12.7).tap do |angle|
          _(angle.deg).must_equal -12.7
          _(angle.suffix).must_be :nil?
        end
      end

      it "truncates angles beyond -360 and 360 degrees" do
        _(AIXM.a(-361).deg).must_equal -1
        _(AIXM.a(-360).deg).must_equal 0
        _(AIXM.a(360).deg).must_equal 0
        _(AIXM.a(361).deg).must_equal 1
      end
    end
  end

  describe :to_i do
    it "returns positive Integer" do
      _(AIXM.a(151.7).to_i).must_equal 152
      _(AIXM.a(-151.7).to_i).must_equal 208
    end

    it "returns values in the range of 0..359" do
      { -360 => 0, -359.9 => 0, -359 => 1, 359 => 359, 359.9 => 0, 360 => 0 }.each do |from, to|
        _(AIXM.a(from).to_i).must_equal to
      end
    end
  end

  describe :to_f do
    it "returns positive Float" do
      _(AIXM.a(151.7).to_f).must_equal 151.7
      _(AIXM.a(-151.7).to_f).must_equal 208.3
    end

    it "returns values in the range of 0.0..359.9~" do
      { -360 => 0.0, -359.9 => 0.1, -359 => 1.0, 359 => 359.0, 359.9 => 359.9, 360 => 0.0 }.each do |from, to|
        _(AIXM.a(from).to_f).must_be_same_as to
      end
    end
  end

  describe :to_s do
    context "type :human" do
      it "returns String of degrees in human readable form" do
        _(AIXM.a(151.72).to_s).must_equal "151.72°"
      end

      it "returns values within -359.9~°..359.9~°" do
        { -360 => '0°', -359.9 => '-359.9°', -359 => '-359°', 359 => '359°', 359.9 => '359.9°', 360 => '0°' }.each do |from, to|
          _(AIXM.a(from).to_s).must_equal to
        end
      end
    end

    context "type :runway" do
      it "returns String of 10 degrees steps with suffix" do
        _(AIXM.a('15L').to_s(:runway)).must_equal '15L'
      end

      it "returns String of 10 degrees steps without suffix" do
        _(AIXM.a(161.7).to_s(:runway)).must_equal '16'
      end

      it 'returns values within "01".."36"' do
        { 0 => '36', 1 => '36', 10 => '01', 352 => '35', 359 => '36', 360 => '36' }.each do |from, to|
          _(AIXM.a(from).to_s(:runway)).must_equal to
        end
      end
    end

    context "type :bearing" do
      it "returns String of zero-padded degrees" do
        _(AIXM.a(51.72).to_s(:bearing)).must_equal '051.7200'
      end

      it 'returns values within "000.0000".."359.9999"' do
        { 0 => '000.0000', 1 => '001.0000', 10 => '010.0000', 352.3 => '352.3000', 352.55555 => '352.5556', 359.9999 => '359.9999', 360 => '000.0000' }.each do |from, to|
          _(AIXM.a(from).to_s(:bearing)).must_equal to
        end
      end
    end
  end

  describe :deg= do
    it "fails on invalid values" do
      _([:foobar, '1', nil]).wont_be_written_to subject, :deg
    end

    it "truncates values to the range -360 < value < 360" do
      { -400 => -40.0, -360 => 0.0, -359.9 => -359.9, 359.9 => 359.9, 360 => 0.0, 400 => 40.0 }.each do |from, to|
        _(AIXM.a(from).deg.to_f).must_be_same_as to
      end
    end
  end

  describe :suffix= do
    it "fails on invalid values" do
      _([123, 'r', 'RR']).wont_be_written_to subject, :suffix
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :suffix
    end

    it "symbolizes valid values" do
      _(subject.tap { _1.suffix = 'R' }.suffix).must_equal :R
    end
  end

  describe :invert do
    it "must calculate inverse of positive deg correctly" do
      { 0 => 180, 10.7 => 190.7, 90 => 270, 179 => 359, 180 => 0 }.each do |from, to|
        _(AIXM.a(from).invert.deg).must_equal to
      end
    end

    it "must calculate inverse of negative deg correctly" do
      { -359 => -179, -180 => 0, -10.7 => -190.7 }.each do |from, to|
        _(AIXM.a(from).invert.deg).must_equal to
      end
    end

    it "must invert left/right suffix" do
      _(AIXM.a('34L').invert.suffix).must_equal :R
    end

    it "must leave other suffixes untouched" do
      _(AIXM.a('35C').invert.suffix).must_equal :C
    end
  end

  describe :inverse_of? do
    it "must return true for inverse pairs" do
      _(AIXM.a('34L').inverse_of?(AIXM.a('16R'))).must_equal true
    end

    it "must return false for non-inverse pairs" do
      _(AIXM.a('34L').inverse_of?(AIXM.a('12L'))).must_equal false
    end
  end

  describe :-@ do
    it "negates the degrees" do
      _(-AIXM.a(5)).must_equal AIXM.a(-5)
    end
  end

  describe :+ do
    it "adds Numeric as degrees" do
      _(subject + 5).must_equal AIXM.a(5)
      _(subject + 370).must_equal AIXM.a(10)
      _(AIXM.a(-15) + 30).must_equal AIXM.a(15)
    end

    it "adds another angle" do
      _(subject + AIXM.a(11)).must_equal AIXM.a(11)
    end
  end

  describe :- do
    it "subtracts Numeric as degrees" do
      _(subject - 5).must_equal AIXM.a(-5)
      _(subject - 370).must_equal AIXM.a(-10)
      _(AIXM.a(15) - 30).must_equal AIXM.a(-15)
    end

    it "subtracts another angle" do
      _(subject - AIXM.a(11)).must_equal AIXM.a(-11)
    end
  end

  describe :== do
    it "recognizes angles with identical deg and suffix as equal" do
      _(AIXM.a('34L')).must_equal AIXM.a('34L')
    end

    it "recognizes angles with different deg or suffix as unequal" do
      _(AIXM.a('34L')).wont_equal AIXM.a('35L')
      _(AIXM.a('34L')).wont_equal AIXM.a('34R')
    end

    it "recognizes objects of different class as unequal" do
      _(subject).wont_equal :oggy
    end
  end

  describe :hash do
    it "returns an integer" do
      _(subject.hash).must_be_instance_of Integer
    end

    it "returns unique hash based on deg" do
      _(AIXM.a(10).hash).must_equal AIXM.a(10).hash
      _(AIXM.a(10).hash).wont_equal AIXM.a(11).hash
    end

    it "returns unique hash based on suffix" do
      _(AIXM.a('01L').hash).must_equal AIXM.a('01L').hash
      _(AIXM.a('01L').hash).wont_equal AIXM.a('01R').hash
      _(AIXM.a('01L').hash).wont_equal AIXM.a(10).hash
    end

    it "allows for the use of instances as hash keys" do
      dupe = subject.dup
      _({ subject => true }[dupe]).must_equal true
    end
  end
end
