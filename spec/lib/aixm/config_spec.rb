require_relative '../../spec_helper'

describe AIXM do
  describe :initialize_config do
    it "must use AIXM" do
      AIXM.send :initialize_config
      _(AIXM.schema).must_equal :aixm
    end
  end

  describe :config do
    it "must set and get arbitrary config options" do
      AIXM.config.foo = :bar
      _(AIXM.config.foo).must_equal :bar
    end
  end

  describe :schema do
    it "must return schema identifier" do
      AIXM.aixm!
      _(AIXM.schema).must_equal :aixm
    end

    it "must return schema details" do
      AIXM.aixm!
      _(AIXM.schema(:root)).must_equal 'AIXM-Snapshot'
    end
  end

  describe "<schema>! and <schema>?" do
    it "must set and query schemas" do
      AIXM.aixm!
      _(AIXM).must_be :aixm?
      _(AIXM).wont_be :ofmx?
      AIXM.ofmx!
      _(AIXM).wont_be :aixm?
      _(AIXM).must_be :ofmx?
    end
  end

end
