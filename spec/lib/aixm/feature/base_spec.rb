require_relative '../../../spec_helper'

describe AIXM::Feature::Base do
  subject do
    AIXM::Feature::Base.send(:new)
  end

  describe :region= do
    it "fails on invalid values" do
      -> { subject.region = 123 }.must_raise ArgumentError
    end

    it "accepts nil value" do
      subject.tap { |s| s.region = nil }.region.must_be :nil?
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

end
