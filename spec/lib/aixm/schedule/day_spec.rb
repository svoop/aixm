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

    it "accepts a valid day as Integer" do
      { 0 => :sunday, 1 => :monday, 2 => :tuesday, 3 => :wednesday, 4 => :thursday, 5 => :friday, 6 => :saturday }.each do |index, day|
        _(AIXM.day(index).day).must_equal day
      end
    end

    it "uses :any as default" do
      _(AIXM.day.day).must_equal :any
    end

    it "fails on anything else" do
      [-1, 7, 123, nil].each do |day|
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

  describe :== do
    it "returns true for equal days" do
      _(AIXM.day(:monday)).must_equal AIXM.day(:monday)
    end

    it "returns false for different days" do
      _(AIXM.day(:monday)).wont_equal AIXM.day(:tuesday)
    end
  end

  describe :any? do
    it "returns true if day is set to :any" do
      _(AIXM::ANY_DAY).must_be :any?
    end

    it "returns false if day is set to anything but :any" do
      (AIXM::Schedule::Day::DAYS - [:any]).each do |day|
        _(AIXM.day(day)).wont_be :any?
      end
    end
  end

  describe :sortable? do
    it "returns true for sortable days" do
      AIXM::Schedule::Day::SORTABLE_DAYS.each do |day|
        _(AIXM.day(day)).must_be :sortable?
      end
    end

    it "returns false for other days" do
      (AIXM::Schedule::Day::DAYS - AIXM::Schedule::Day::SORTABLE_DAYS).each do |day|
        _(AIXM.day(day)).wont_be :sortable?
      end
    end
  end

  describe :covered_by? do
    context "any day" do
      subject do
        AIXM::ANY_DAY
      end

      it "returns true for any weekday or :any" do
        %i(monday tuesday wednesday thursday friday saturday sunday any).each do |day|
          _(AIXM.day(day).covered_by?(subject)).must_equal true
        end
      end
    end

    context "single day" do
      subject do
        AIXM.day(:monday)
      end

      it "returns true if equal" do
        _(AIXM.day(:monday).covered_by?(subject)).must_equal true
      end

      it "returns false unless equal" do
        %i(tuesday wednesday thursday friday saturday sunday).each do |day|
          _(AIXM.day(day).covered_by?(subject)).wont_equal true
        end
      end
    end

    context "range of days" do
      subject do
        (AIXM.day(:monday)..AIXM.day(:thursday))
      end

      it "returns true if wthin range" do
        %i(monday tuesday wednesday thursday).each do |day|
          _(AIXM.day(day).covered_by?(subject)).must_equal true
        end
      end

      it "returns false if out of range" do
        %i(friday saturday sunday).each do |day|
          _(AIXM.day(day).covered_by?(subject)).must_equal false
        end
      end
    end

    context "range of days across end of week boundary" do
      subject do
        (AIXM.day(:thursday)..AIXM.day(:monday))
      end

      it "returns true if wthin range" do
        %i(thursday friday saturday sunday monday).each do |day|
          _(AIXM.day(day).covered_by?(subject)).must_equal true
        end
      end

      it "returns false if out of range" do
        %i(tuesday wednesday).each do |day|
          _(AIXM.day(day).covered_by?(subject)).must_equal false
        end
      end
    end

    context "unsortable ranges with non-weekdays" do
      it "accepts non-weekdays in range" do
        _((AIXM.day(:monday)..AIXM.day(:holiday)))
        _((AIXM.day(:holiday)..AIXM.day(:monday)))
        _((AIXM.day(:holiday)..AIXM.day(:day_following_workday)))
      end

      it "fails if subject is unsortable" do
        _{ AIXM.day(:holiday).covered_by?((AIXM.day(:monday)..AIXM.day(:friday))) }.must_raise RuntimeError
      end

      it "fails if range contains unsortable" do
        _{ AIXM.day(:monday).covered_by?((AIXM.day(:holiday)..AIXM.day(:friday))) }.must_raise RuntimeError
      end
    end
  end
end
