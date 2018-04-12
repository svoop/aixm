require_relative '../../../spec_helper'

describe AIXM::Feature::NavigationalAid do
  subject do
    AIXM::Feature::NavigationalAid.send(:new,
      organisation: AIXM::Factory.organisation,
      id: 'XXX',
      xy: AIXM::Factory.xy
    )
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
      [:foobar, 123].wont_be_written_to subject, :name
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :name
    end

    it "upcases and transcodes value" do
      subject.tap { |s| s.name = 'löl' }.name.must_equal 'LOEL'
    end
  end

  describe :xy= do
    macro :xy
  end

  describe :z= do
    macro :z_qnh

    it "accepts nil value" do
      [nil].must_be_written_to subject, :z
    end
  end

  describe :remarks= do
    macro :remarks
  end

end
