require_relative '../../spec_helper'

describe AIXM do
  describe :format do
    it "must return format identifier" do
      AIXM.aixm!
      AIXM.format.must_equal :aixm
    end

    it "must return format details" do
      AIXM.aixm!
      AIXM.format(:root).must_equal 'AIXM-Snapshot'
    end
  end

  describe "<format>! and <format>?" do
    it "must set and query formats" do
      AIXM.aixm!
      AIXM.must_be :aixm?
      AIXM.wont_be :ofmx?
      AIXM.ofmx!
      AIXM.wont_be :aixm?
      AIXM.must_be :ofmx?
    end
  end

end
