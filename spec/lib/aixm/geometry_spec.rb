require_relative '../../spec_helper'

describe AIXM::Geometry do
  subject do
    AIXM::Geometry.new.tap do |geometry|
      geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
      geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 22, long: 33))
      geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 33, long: 44))
    end
  end

  it "must recognize unclosed" do
    subject.wont_be :closed?
  end

  it "must recognize closed" do
    subject << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
    subject.must_be :closed?
  end
end
