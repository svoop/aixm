require_relative '../../spec_helper'

describe AIXM::W do
  subject do
    AIXM::Factory.w
  end

  describe :wgt= do
    it "fails on invalid values" do
      _([:foobar, -1]).wont_be_written_to subject, :wgt
    end

    it "converts Numeric to Float" do
      _(subject.tap { _1.wgt = 5 }.wgt).must_equal 5.0
    end
  end

  describe :unit= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :unit
    end

    it "symbolizes and downcases values" do
      _(subject.tap { _1.unit = "KG" }.unit).must_equal :kg
    end
  end

  describe :to_kg do
    it "leaves kilograms untouched" do
      subject = AIXM.w(2, :kg)
      _(subject.to_kg).must_be_same_as subject
    end

    it "converts metric tonnes to kilograms" do
      _(AIXM.w(0.5, :t).to_kg).must_equal AIXM.w(500, :kg)
    end

    it "converts pound to kilograms" do
      _(AIXM.w(200, :lb).to_kg).must_equal AIXM.w(90.718474, :kg)
    end

    it "converts US tons to kilograms" do
      _(AIXM.w(0.5, :ton).to_kg).must_equal AIXM.w(453.59237, :kg)
    end
  end

  describe :to_t do
    it "leaves metric tonnes untouched" do
      subject = AIXM.w(2, :t)
      _(subject.to_t).must_be_same_as subject
    end

    it "converts kilograms to metric tonnes" do
      _(AIXM.w(10_000, :kg).to_t).must_equal AIXM.w(10, :t)
    end

    it "converts pound to metric tonnes" do
      _(AIXM.w(1000, :lb).to_t).must_equal AIXM.w(0.45359237, :t)
    end

    it "converts US tons to metric tonnes" do
      _(AIXM.w(1, :ton).to_t).must_equal AIXM.w(0.90718474, :t)
    end
  end

  describe :to_lb do
    it "leaves pound untouched" do
      subject = AIXM.w(2, :lb)
      _(subject.to_lb).must_be_same_as subject
    end

    it "converts kilograms to pound" do
      _(AIXM.w(50, :kg).to_lb).must_equal AIXM.w(110.2311311, :lb)
    end

    it "converts metric tonnes to pound" do
      _(AIXM.w(0.5, :t).to_lb).must_equal AIXM.w(1102.311311, :lb)
    end

    it "converts US tons to pound" do
      _(AIXM.w(0.5, :ton).to_lb).must_equal AIXM.w(1000.00000007, :lb)
    end
  end

  describe :to_ton do
    it "leaves US tons untouched" do
      subject = AIXM.w(2, :ton)
      _(subject.to_ton).must_be_same_as subject
    end

    it "converts kilograms to US tons" do
      _(AIXM.w(1000, :kg).to_ton).must_equal AIXM.w(1.10231131, :ton)
    end

    it "converts metrical tons to US tons" do
      _(AIXM.w(0.5, :t).to_ton).must_equal AIXM.w(0.55115566, :ton)
    end

    it "converts pound to US tons" do
      _(AIXM.w(3000, :lb).to_ton).must_equal AIXM.w(1.5, :ton)
    end
  end

  describe :<=> do
    it "recognizes objects with identical unit and weight as equal" do
      a = AIXM.w(123, :kg)
      b = AIXM.w(123.0, 'KG')
      _(a).must_equal b
    end

    it "recognizes objects with different units and converted weight as equal" do
      a = AIXM.w(123, :kg)
      b = AIXM.w(271.16858251, 'LB')
      _(a).must_equal b
    end

    it "recognizes objects with different units and identical weight as unequal" do
      a = AIXM.w(123, :kg)
      b = AIXM.w(123, :lb)
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.w(123, :kg)
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
    it "returns true for zero weight" do
      _(subject.tap { _1.wgt = 0 }).must_be :zero?
    end

    it "returns false for non-zero weight" do
      _(subject.tap { _1.wgt = 1 }).wont_be :zero?
    end
  end
end
