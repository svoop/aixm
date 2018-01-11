require_relative '../../spec_helper'

describe AIXM do
  it "must be defined" do
    AIXM::VERSION.wont_be_nil
  end
end
