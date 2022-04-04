require_relative '../../../spec_helper'

describe AIXM::Schedule::Time do
  subject do
    AIXM::Factory.time
  end

  describe :initialize, :to_datetime do
    it "parses valid HH:MM string as UTC" do
      datetime = subject.to_datetime
      _(datetime).must_equal DateTime.parse('8888-08-08 09:00:00 UTC')
      _(datetime.offset).must_be :zero?
    end

    it "parses valid HH:MM [+-]0000 string to UTC" do
      datetime = AIXM.time('14:05 +0300').to_datetime
      _(datetime).must_equal DateTime.parse('8888-08-08 11:05:00 UTC')
      _(datetime.offset).must_be :zero?
    end

    it "parses valid HH:MM ZZZ string to UTC" do
      datetime = AIXM.time('14:05 CEST').to_datetime
      _(datetime).must_equal DateTime.parse('8888-08-08 12:05:00 UTC')
      _(datetime.offset).must_be :zero?
    end

    it "accepts a stdlib DateTime to UTC" do
      datetime = AIXM.time(DateTime.parse('19:15:00 +0200')).to_datetime
      _(datetime).must_equal DateTime.parse('8888-08-08 17:15:00 UTC')
      _(datetime.offset).must_be :zero?
    end

    it "accepts a sdtlib Time to UTC" do
      datetime = AIXM.time(Time.parse('20:15:00 -0200')).to_datetime
      _(datetime).must_equal DateTime.parse('8888-08-08 22:15:00 UTC')
      _(datetime.offset).must_be :zero?
    end

    it "accepts a valid event" do
      AIXM::Schedule::Time::EVENTS.each do |event|
        _(AIXM.time('08:00', or: event).event).must_equal event
      end
    end

    it "accepts nil event" do
      _(AIXM.time('08:00', or: nil).event).must_be :nil?
    end

    it "fails on invalid event" do
      _{ AIXM.time('08:00', or: :foobar) }.must_raise ArgumentError
    end

    it "accepts event with delta" do
      _(AIXM.time('08:00', or: :sunrise, plus: 15).delta).must_equal 15
      _(AIXM.time('08:00', or: :sunrise, minus: 30).delta).must_equal(-30)
      _(AIXM.time('08:00', or: :sunrise, plus: 15, minus: 30).delta).must_equal(-15)
    end

    it "sets delta to zero if no event is given" do
      _(AIXM.time('08:00', plus: 15).delta).must_equal 0
      _(AIXM.time('08:00', minus: 15).delta).must_equal 0
    end

    it "accepts a valid precedence" do
      AIXM::Schedule::Time::PRECEDENCES.each do |precedence|
        _(AIXM.time('08:00', or: :sunrise, whichever_comes: precedence).precedence).must_equal precedence
      end
    end

    it "defaults to precedence :first" do
      _(AIXM.time('08:00', or: :sunrise).precedence).must_equal :first
    end

    it "fails on invalid precedence" do
      _{ AIXM.time('08:00', or: :sunrise, whichever_comes: :foobar) }.must_raise ArgumentError
      _{ AIXM.time('08:00', or: :sunrise, whichever_comes: nil) }.must_raise ArgumentError
    end

    it "sets precedence to nil if no event is given" do
      _(AIXM.time('08:00', whichever_comes: :first).precedence).must_be :nil?
    end
  end

  describe :to_s do
    it "returns HH:MM UTC" do
      _(subject.to_s).must_equal '09:00 UTC'
    end

    it "returns HH:MM UTC EEEEE" do
      _(AIXM::Factory.time_with_event.to_s).must_equal "21:20 UTC or sunset whichever comes first"
      _(AIXM::Factory.time_with_delta.to_s).must_equal "21:20 UTC or sunset+15min whichever comes first"
      _(AIXM::Factory.time_with_precedence.to_s).must_equal "21:20 UTC or sunset+15min whichever comes last"
    end

    it "applies given format" do
      _(subject.to_s('%H')).must_equal '09'
    end
  end

  describe :comparable? do
    it "returns true for times without event" do
      _(AIXM::Factory.time).must_be :comparable?
    end

    it "returns false for times with event" do
      _(AIXM::Factory.time_with_event).wont_be :comparable?
    end
  end

  describe :in? do
    it "fails if subject or range are incomparable" do
      _{ AIXM::Factory.time_with_event.in?(AIXM.time('10:00')..AIXM.time('15:00')) }.must_raise RuntimeError
      _{ AIXM::Factory.time.in?(AIXM.time('10:00', or: :sunrise)..AIXM.time('15:00')) }.must_raise RuntimeError
    end

    context "range of times" do
      subject do
        (AIXM.time('10:00')..AIXM.time('15:00'))
      end

      it "returns true if wthin range" do
        %w(10:00 12:12 15:00).each do |string|
          _(AIXM.time(string).in?(subject)).must_equal true
        end
      end

      it "returns false if out of range" do
        %w(15:01 20:20 24:00 00:00 09:59).each do |string|
          _(AIXM.time(string).in?(subject)).must_equal false
        end
      end
    end

    context "range of times across end of day boundary" do
      subject do
        (AIXM.time('15:00')..AIXM.time('10:00'))
      end

      it "returns true if wthin range" do
        %w(15:00 20:20 24:00 00:00 10:00).each do |string|
          _(AIXM.time(string).in?(subject)).must_equal true
        end
      end

      it "returns false if out of range" do
        %w(10:01 12:12 14:59).each do |string|
          _(AIXM.time(string).in?(subject)).must_equal false
        end
      end
    end
  end
end
