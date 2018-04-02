require_relative '../../spec_helper'

describe AIXM do
  describe :initialize_config do
    it "must use AIXM" do
      AIXM.send :initialize_config
      AIXM.format.must_equal :aixm
    end
  end

  describe :config do
    it "must set and get arbitrary config options" do
      AIXM.config.foo = :bar
      AIXM.config.foo.must_equal :bar
    end
  end

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
