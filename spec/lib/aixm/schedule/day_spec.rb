require_relative '../../../spec_helper'

describe AIXM::Schedule::Day do
  subject do
    AIXM::Factory.day
  end

  describe :initialize do
    it "accepts a valid days as Symbol or String" do
      AIXM::Schedule::Day::DAYS.each do |day|
        _(AIXM.day(day).day).must_equal day
        _(AIXM.day(day.to_s).day).must_equal day
      end
    end

    it "uses :any as default" do
      _(AIXM.day.day).must_equal :any
    end

    it "fails on anything else" do
      [123, nil].each do |day|
        _{ AIXM.day(day) }.must_raise ArgumentError
      end
    end
  end

  describe :to_s do
    it "day String without underscores" do
      _(subject.to_s).must_equal 'monday'
      _(AIXM::Factory.special_day.to_s).must_equal 'day preceding holiday'
    end
  end

  describe :comparable? do
    it "returns true for comparable days" do
      AIXM::Schedule::Day::COMPARABLE_DAYS.each do |day|
        _(AIXM.day(day)).must_be :comparable?
      end
    end

    it "returns false for other days" do
      (AIXM::Schedule::Day::DAYS - AIXM::Schedule::Day::COMPARABLE_DAYS).each do |day|
        _(AIXM.day(day)).wont_be :comparable?
      end
    end
  end

  describe :in? do
    it "fails if subject or range are incomparable" do
      _{ AIXM::Factory.special_day.in?(AIXM.day(:monday)..AIXM.day(:thursday)) }.must_raise RuntimeError
      _{ AIXM::Factory.day.in?(AIXM.day(:workday)..AIXM.day(:thursday)) }.must_raise RuntimeError
    end

    context "range of days" do
      subject do
        (AIXM.day(:monday)..AIXM.day(:thursday))
      end

      it "returns true if wthin range" do
        %i(monday tuesday wednesday thursday).each do |day|
          _(AIXM.day(day).in?(subject)).must_equal true
        end
      end

      it "returns false if out of range" do
        %i(friday saturday sunday).each do |day|
          _(AIXM.day(day).in?(subject)).must_equal false
        end
      end
    end

    context "range of days across end of week boundary" do
      subject do
        (AIXM.day(:thursday)..AIXM.day(:monday))
      end

      it "returns true if wthin range" do
        %i(thursday friday saturday sunday monday).each do |day|
          _(AIXM.day(day).in?(subject)).must_equal true
        end
      end

      it "returns false if out of range" do
        %i(tuesday wednesday).each do |day|
          _(AIXM.day(day).in?(subject)).must_equal false
        end
      end
    end
  end
end
