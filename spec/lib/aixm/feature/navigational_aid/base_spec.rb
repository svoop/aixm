require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::Base do
  subject do
    AIXM::Feature::NavigationalAid::Base.send(:new, id: 'XXX', xy: AIXM::Factory.xy)
  end

  describe :id= do
    it "fails on invalid values" do
      -> { subject.id = 123 }.must_raise ArgumentError
    end

    it "upcases value" do
      subject.tap { |s| s.id = 'lol' }.id.must_equal 'LOL'
    end
  end

  describe :name= do
    it "fails on invalid values" do
      -> { subject.name = 123 }.must_raise ArgumentError
    end

    it "accepts nil value" do
      subject.tap { |s| s.name = nil }.name.must_be :nil?
    end

    it "uptranses value" do
      subject.tap { |s| s.name = 'löl' }.name.must_equal 'LOEL'
    end
  end

  describe :xy= do
    it "fails on invalid values" do
      -> { subject.xy = 123 }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.xy = AIXM::Factory.xy }.xy.must_equal AIXM::Factory.xy
    end
  end

  describe :xy= do
    it "fails on invalid values" do
      -> { subject.z = 123 }.must_raise ArgumentError
      -> { subject.z = AIXM.z(123, :qfe) }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.z = AIXM.z(123, :qnh) }.z.must_equal AIXM.z(123, :qnh)
    end
  end

end
