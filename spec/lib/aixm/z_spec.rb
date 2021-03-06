require_relative '../../spec_helper'

describe AIXM::Z do
  subject do
    AIXM::Factory.z
  end

  describe :alt= do
    it "fails on invalid values" do
      _([:foobar]).wont_be_written_to subject, :alt
    end

    it "converts Numeric to Integer" do
      _(subject.tap { _1.alt = 5.5 }.alt).must_equal 5
    end
  end

  describe :code= do
    it "fails on invalid values" do
      _([nil, :foobar]).wont_be_written_to subject, :code
    end

    it "symbolizes and downcases values" do
      _(subject.tap { _1.code = "QFE" }.code).must_equal :qfe
    end
  end

  describe :qfe? do
    it "recognizes same Q code" do
      _(AIXM.z(111, :qfe)).must_be :qfe?
    end

    it "doesn't recognize different Q code" do
      _(AIXM.z(111, :qnh)).wont_be :qfe?
    end
  end

  describe :ground? do
    it "must detect ground" do
      _(AIXM.z(0, :qfe)).must_be :ground?
      _(AIXM.z(111, :qfe)).wont_be :ground?
      _(AIXM.z(0, :qnh)).wont_be :ground?
    end
  end

  describe :unit do
    it "must return the correct unit" do
      _(AIXM.z(0, :qfe).unit).must_equal :ft
      _(AIXM.z(0, :qnh).unit).must_equal :ft
      _(AIXM.z(0, :qne).unit).must_equal :fl
    end
  end

  describe :== do
    it "recognizes objects with identical altitude and Q code as equal" do
      a = AIXM.z(111, :qnh)
      b = AIXM.z(111, :qnh)
      _(a).must_equal b
    end

    it "recognizes objects with different altitude or Q code as unequal" do
      a = AIXM.z(111, :qnh)
      b = AIXM.z(222, :qnh)
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.z(111, :qnh)
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
    it "returns true for zero height, elevation or altitude" do
      _(subject.tap { _1.alt = 0 }).must_be :zero?
    end

    it "returns false for non-zero height, elevation or altitude" do
      _(subject.tap { _1.alt = 1 }).wont_be :zero?
    end
  end
end
