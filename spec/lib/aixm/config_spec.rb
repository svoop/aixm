require_relative '../../spec_helper'

describe AIXM do
  describe :initialize_config do
    it "must setup defaults" do
      AIXM.config.extensions.must_equal AIXM::EXTENSIONS
    end
  end

  describe :setup do
    it "must apply proc" do
      saved_config = AIXM.config.dup
      AIXM.setup do |config|
        config.test_only = :test_only
      end
      AIXM.config.extensions.must_equal AIXM::EXTENSIONS
      AIXM.config.test_only.must_equal :test_only
      AIXM.class_variable_set :@@config, saved_config
    end
  end

  describe :extension? do
    it "must return true for active extensions" do
      AIXM.must_be :ofm?
    end

    it "must return false for inactive or unknown extensions" do
      AIXM.wont_be :foobar?
    end
  end


end
