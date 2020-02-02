require_relative '../../spec_helper'

describe AIXM::Feature do
  subject do
    AIXM.config.region = 'ZZ'
    AIXM::Feature.send(:new)
  end

  describe :initialize do
    it "falls back to default region" do
      _(subject.region).must_equal 'ZZ'
    end
  end

  describe :source= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :source
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :source
    end
  end

  describe :region= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :region
    end

    it "fails on invalid values" do
      _([:foobar, 123, 'A', 'AAA']).wont_be_written_to subject, :region
    end

    it "upcases valid values" do
      _(subject.tap { |s| s.region = 'lf' }.region).must_equal 'LF'
    end
  end

  describe :== do
    it "recognizes features with identical UID as equal" do
      a = AIXM::Factory.organisation
      b = AIXM::Factory.organisation
      _(a).must_equal b
    end

    it "recognizes features with different UID as unequal" do
      a = AIXM::Factory.polygon_airspace
      b = AIXM::Factory.circle_airspace
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM::Factory.organisation
      b = :oggy
      _(a).wont_equal b
    end
  end

end
