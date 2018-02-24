require_relative '../../spec_helper'

describe AIXM do
  describe :format do
    it "must return format" do
      AIXM.aixm!
      AIXM.format.must_equal :aixm
    end
  end

  describe :format_schema do
    it "must return schema for format" do
      AIXM.aixm!
      AIXM.format_schema.to_s.must_match(/xsd$/)
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
