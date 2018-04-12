require_relative '../../spec_helper'

describe AIXM::Feature do
  subject do
    AIXM::Feature.send(:new)
  end

  describe :source= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :source
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :source
    end
  end

  describe :region= do
    it "fails on invalid values" do
      -> { subject.region = 123 }.must_raise ArgumentError
    end

    it "accepts nil value" do
      subject.tap { |s| s.region = nil }.region.must_be_nil
    end

    it "upcases value" do
      subject.tap { |s| s.region = 'lol' }.region.must_equal 'LOL'
    end

    it "falls back to configuration default" do
      AIXM.config.region = 'foo'
      subject.region.must_equal 'FOO'
      AIXM.config.region = nil
    end
  end

  describe :== do
    it "recognizes features with identical UID as equal" do
      a = AIXM::Factory.organisation
      b = AIXM::Factory.organisation
      a.must_equal b
    end

    it "recognizes features with different UID as unequal" do
      a = AIXM::Factory.polygon_airspace
      b = AIXM::Factory.circle_airspace
      a.wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM::Factory.organisation
      b = :oggy
      a.wont_equal b
    end
  end

end
