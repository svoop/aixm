require_relative '../../spec_helper'

describe AIXM::P do
  subject do
    AIXM::Factory.p
  end

  describe :pres= do
    it "fails on invalid values" do
      _([:foobar, -1]).wont_be_written_to subject, :pres
    end

    it "converts Numeric to Float" do
      _(subject.tap { _1.pres = 5 }.pres).must_equal 5.0
    end
  end

  describe :unit= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :unit
    end

    it "symbolizes and downcases values" do
      _(subject.tap { _1.unit = "P" }.unit).must_equal :p
    end
  end

  describe :to_p do
    it "leaves pascal untouched" do
      subject = AIXM.p(2, :p)
      _(subject.to_p).must_be_same_as subject
    end

    it "converts megapascal to pascal" do
      _(AIXM.p(0.01, :mpa).to_p).must_equal AIXM.p(10_000, :p)
    end

    it "converts psi to pascal" do
      _(AIXM.p(0.03, :psi).to_p).must_equal AIXM.p(206.8427187, :p)
    end

    it "converts bar to pascal" do
      _(AIXM.p(0.02, :bar).to_p).must_equal AIXM.p(2000, :p)
    end

    it "converts mmhg to pascal" do
      _(AIXM.p(0.02, :torr).to_p).must_equal AIXM.p(2.66644, :p)
    end
  end

  describe :to_mpa do
    it "leaves megapascal untouched" do
      subject = AIXM.p(2, :mpa)
      _(subject.to_mpa).must_be_same_as subject
    end

    it "converts pascal to megapascal" do
      _(AIXM.p(10_000, :p).to_mpa).must_equal AIXM.p(0.01, :mpa)
    end

    it "converts psi to megapascal" do
      _(AIXM.p(300, :psi).to_mpa).must_equal AIXM.p(2.06842719, :mpa)
    end

    it "converts bar to megapascal" do
      _(AIXM.p(22, :bar).to_mpa).must_equal AIXM.p(2.2, :mpa)
    end

    it "converts mmhg to megapascal" do
      _(AIXM.p(205, :torr).to_mpa).must_equal AIXM.p(0.02733101, :mpa)
    end
  end

  describe :to_psi do
    it "leaves psi untouched" do
      subject = AIXM.p(2, :psi)
      _(subject.to_psi).must_be_same_as subject
    end

    it "converts pascal to psi" do
      _(AIXM.p(500, :p).to_psi).must_equal AIXM.p(0.07251887, :psi)
    end

    it "converts megapascal to psi" do
      _(AIXM.p(0.1, :mpa).to_psi).must_equal AIXM.p(14.5037738, :psi)
    end

    it "converts bar to psi" do
      _(AIXM.p(30, :bar).to_psi).must_equal AIXM.p(435.113214, :psi)
    end

    it "converts mmhg to psi" do
      _(AIXM.p(20, :torr).to_psi).must_equal AIXM.p(0.38673443, :psi)
    end
  end

  describe :to_bar do
    it "leaves bars untouched" do
      subject = AIXM.p(2, :bar)
      _(subject.to_bar).must_be_same_as subject
    end

    it "converts pascal to bars" do
      _(AIXM.p(10_000, :p).to_bar).must_equal AIXM.p(0.1, :bar)
    end

    it "converts megapascal to bars" do
      _(AIXM.p(0.1, :mpa).to_bar).must_equal AIXM.p(1, :bar)
    end

    it "converts psi to bars" do
      _(AIXM.p(90, :psi).to_bar).must_equal AIXM.p(6.20528156, :bar)
    end

    it "converts mmhg to bars" do
      _(AIXM.p(7000, :torr).to_bar).must_equal AIXM.p(9.33254, :bar)
    end
  end

  describe :to_torr do
    it "leaves mmhg untouched" do
      subject = AIXM.p(2, :torr)
      _(subject.to_torr).must_be_same_as subject
    end

    it "converts pascal to mmhg" do
      _(AIXM.p(12_000, :p).to_torr).must_equal AIXM.p(90.0072, :torr)
    end

    it "converts megapascal to mmhg" do
      _(AIXM.p(0.1, :mpa).to_torr).must_equal AIXM.p(750.06, :torr)
    end

    it "converts psi to mmhg" do
      _(AIXM.p(2, :psi).to_torr).must_equal AIXM.p(103.42963306, :torr)
    end

    it "converts bar to mmhg" do
      _(AIXM.p(0.35, :bar).to_torr).must_equal AIXM.p(262.521, :torr)
    end
  end

  describe :<=> do
    it "recognizes objects with identical unit and pressure as equal" do
      a = AIXM.p(12, :bar)
      b = AIXM.p(12.0, 'BAR')
      _(a).must_equal b
    end

    it "recognizes objects with different units and converted pressure as equal" do
      a = AIXM.p(12, :bar)
      b = AIXM.p(174.0452856, 'PSI')
      _(a).must_equal b
    end

    it "recognizes objects with different units and identical pressure as unequal" do
      a = AIXM.p(12, :bar)
      b = AIXM.p(12, :p)
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.p(12, :bar)
      b = :oggy
      _(a).wont_equal b
    end
  end

  describe :hash do
    it "returns an integer" do
      _(subject.hash).must_be_instance_of Integer
    end

    it "allows for the use of instances as hash keys" do
      dupe = subject.dup
      _({ subject => true }[dupe]).must_equal true
    end
  end

  describe :zero? do
    it "returns true for zero pressure" do
      _(subject.tap { _1.pres = 0 }).must_be :zero?
    end

    it "returns false for non-zero pressure" do
      _(subject.tap { _1.pres = 1 }).wont_be :zero?
    end
  end
end
