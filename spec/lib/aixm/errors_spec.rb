require_relative '../../spec_helper'

describe AIXM::GeometryError do
  it "must be defined" do
    _(AIXM::GeometryError).wont_be_nil
  end
end


describe AIXM::LayerError do
  it "must be defined" do
    _(AIXM::LayerError).wont_be_nil
  end
end
