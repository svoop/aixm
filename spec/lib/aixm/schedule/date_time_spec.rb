require_relative '../../../spec_helper'

describe AIXM::Schedule::DateTime do
  subject do
    AIXM::Factory.datetime
  end

  describe :initialize do
    it "fails but on date and time" do
      _{ AIXM.datetime(AIXM::Factory.date, :time) }.must_raise ArgumentError
      _{ AIXM.datetime(:date, AIXM::Factory.time) }.must_raise ArgumentError
      _{ AIXM.datetime(:time, :date) }.must_raise ArgumentError
      AIXM.datetime(AIXM::Factory.date, AIXM::Factory.time)
    end
  end

  describe :date do
    it "returns the date part" do
       _(subject.date).must_be_instance_of AIXM::Schedule::Date
    end
  end

  describe :time do
    it "returns the time part" do
       _(subject.time).must_be_instance_of AIXM::Schedule::Time
    end
  end
end
