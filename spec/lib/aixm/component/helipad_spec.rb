require_relative '../../../spec_helper'

describe AIXM::Component::Helipad do
  subject do
    AIXM::Factory.airport.helipads.first
  end

  describe :name= do
    it "upcases and transcodes value" do
      subject.tap { |s| s.name = 'h1' }.name.must_equal 'H1'
    end
  end

  describe :xy= do
    macro :xy
  end

  describe :z= do
    macro :z_qnh
  end

  describe :length= do
    it "fails on invalid values" do
      -> { subject.length = :foobar }.must_raise ArgumentError
      -> { subject.length = nil }.must_raise ArgumentError
      -> { subject.length = -1 }.must_raise ArgumentError
    end

    it "converts valid values to integer" do
      subject.tap { |s| s.length = 1000.5 }.length.must_equal 1000
    end
  end

  describe :width= do
    it "fails on invalid values" do
      -> { subject.width = :foobar }.must_raise ArgumentError
      -> { subject.width = nil }.must_raise ArgumentError
      -> { subject.width = -1 }.must_raise ArgumentError
    end

    it "converts valid values to integer" do
      subject.tap { |s| s.width = 150.5 }.width.must_equal 150
    end
  end

  describe :composition= do
    it "fails on invalid values" do
      -> { subject.composition = :foobar }.must_raise ArgumentError
      -> { subject.composition = nil }.must_raise ArgumentError
    end

    it "normalizes valid values" do
      subject.tap { |s| s.composition = :macadam }.composition.must_equal :macadam
      subject.tap { |s| s.composition = :GRADE }.composition.must_equal :graded_earth
    end
  end

  describe :status= do
    it "fails on invalid values" do
      -> { subject.status = :foobar }.must_raise ArgumentError
    end

    it "accepts nil values" do
      subject.tap { |s| s.status = nil }.status.must_be :nil?
    end

    it "normalizes valid values" do
      subject.tap { |s| s.status = :closed }.status.must_equal :closed
      subject.tap { |s| s.status = :SPOWER }.status.must_equal :secondary_power
    end
  end

  describe :remarks= do
    macro :remarks
  end
end
