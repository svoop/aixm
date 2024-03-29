require_relative '../../spec_helper'

describe AIXM::D do
  subject do
    AIXM::Factory.d
  end

  describe :dim= do
    it "fails on invalid values" do
      _([:foobar, -1]).wont_be_written_to subject, :dim
    end

    it "converts Numeric to Float" do
      _(subject.tap { _1.dim = 5 }.dim).must_equal 5.0
    end
  end

  describe :unit= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :unit
    end

    it "symbolizes and downcases values" do
      _(subject.tap { _1.unit = "NM" }.unit).must_equal :nm
    end
  end

  describe :to_ft do
    it "leaves feet untouched" do
      subject = AIXM.d(2, :ft)
      _(subject.to_ft).must_be_same_as subject
    end

    it "converts kilometers to feet" do
      _(AIXM.d(0.5, :km).to_ft).must_equal AIXM.d(1640.4199475, :ft)
    end

    it "converts meters to feet" do
      _(AIXM.d(200, :m).to_ft).must_equal AIXM.d(656.167979, :ft)
    end

    it "converts nautical miles to feet" do
      _(AIXM.d(0.5, :nm).to_ft).must_equal AIXM.d(3038.05774277, :ft)
    end
  end

  describe :to_km do
    it "leaves kilometers untouched" do
      subject = AIXM.d(2, :km)
      _(subject.to_km).must_be_same_as subject
    end

    it "converts feet to kilometers" do
      _(AIXM.d(10_000, :ft).to_km).must_equal AIXM.d(3.048, :km)
    end

    it "converts meters to kilometers" do
      _(AIXM.d(2000, :m).to_km).must_equal AIXM.d(2, :km)
    end

    it "converts nautical miles to kilometers" do
      _(AIXM.d(10, :nm).to_km).must_equal AIXM.d(18.52, :km)
    end
  end

  describe :to_m do
    it "leaves meters untouched" do
      subject = AIXM.d(2, :m)
      _(subject.to_m).must_be_same_as subject
    end

    it "converts feet to meters" do
      _(AIXM.d(500, :ft).to_m).must_equal AIXM.d(152.4, :m)
    end

    it "converts kilometers to meters" do
      _(AIXM.d(1.3, :km).to_m).must_equal AIXM.d(1300, :m)
    end

    it "converts nautical miles to meters" do
      _(AIXM.d(0.8, :nm).to_m).must_equal AIXM.d(1481.6, :m)
    end
  end

  describe :to_nm do
    it "leaves nautical miles untouched" do
      subject = AIXM.d(2, :nm)
      _(subject.to_nm).must_be_same_as subject
    end

    it "converts feet to nautical miles" do
      _(AIXM.d(11_000, :ft).to_nm).must_equal AIXM.d(1.81036717, :nm)
    end

    it "converts kilometers to nautical miles" do
      _(AIXM.d(17, :km).to_nm).must_equal AIXM.d(9.17926565, :nm)
    end

    it "converts meters to nautical miles" do
      _(AIXM.d(5800, :m).to_nm).must_equal AIXM.d(3.13174946, :nm)
    end
  end

  describe :<=> do
    it "recognizes objects with identical unit and distance as equal" do
      a = AIXM.d(123, :m)
      b = AIXM.d(123.0, 'M')
      _(a).must_equal b
    end

    it "recognizes objects with different units and converted distance as equal" do
      a = AIXM.d(123, :m)
      b = AIXM.d(403.54330709, 'FT')
      _(a).must_equal b
    end

    it "recognizes objects with different units and identical distance as unequal" do
      a = AIXM.d(123, :m)
      b = AIXM.d(123, :ft)
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.d(123, :m)
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
    it "returns true for zero distance" do
      _(subject.tap { _1.dim = 0 }).must_be :zero?
    end

    it "returns false for non-zero distance" do
      _(subject.tap { _1.dim = 1 }).wont_be :zero?
    end
  end
end
