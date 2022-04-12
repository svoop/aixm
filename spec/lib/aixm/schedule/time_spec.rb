require_relative '../../../spec_helper'

describe AIXM::Schedule::Time do
  describe :initialize, :time do
    context "time only" do
      it "populates all attributes correctly" do
        subject = AIXM.time('11:11')
        _(subject.to_time).must_equal Time.new(0, 1, 1, 11, 11, 0, 'UTC')
        _(subject.event).must_be :nil?
        _(subject.delta).must_equal 0
        _(subject.precedence).must_be :nil?
      end

      it "sets delta to zero if no alternative event is given" do
        _(AIXM.time('08:00', plus: 15).delta).must_equal 0
        _(AIXM.time('08:00', minus: 15).delta).must_equal 0
      end

      it "sets precedence to nil if no alternative event is given" do
        _(AIXM.time('08:00', whichever_comes: :first).precedence).must_be :nil?
      end

      it "parses valid HH:MM string as UTC" do
        time = AIXM.time('09:00').to_time
        _(time).must_equal Time.new(0, 1, 1, 9, 0, 0, 'UTC')
        _(time.zone).must_equal 'UTC'
      end

      it "parses valid HH:MM [+-]00:00 string to UTC" do
        time = AIXM.time('14:05 +03:00').to_time
        _(time).must_equal Time.new(0, 1, 1, 11, 5, 0, 'UTC')
        _(time.zone).must_equal 'UTC'
      end

      it "parses valid HH:MM UTC string to UTC" do
        time = AIXM.time('14:05 UTC').to_time
        _(time).must_equal Time.new(0, 1, 1, 14, 5, 0, 'UTC')
        _(time.zone).must_equal 'UTC'
      end

      it "accepts stdlib DateTime as UTC" do
        time = AIXM.time(DateTime.parse('19:15:00 +02:00')).to_time
        _(time).must_equal Time.new(0, 1, 1, 17, 15, 0, 'UTC')
        _(time.zone).must_equal 'UTC'
      end

      it "accepts sdtlib Time as UTC" do
        time = AIXM.time(Time.new(0, 1, 1, 20, 15, 0, '-02:00')).to_time
        _(time).must_equal Time.new(0, 1, 1, 22, 15, 0, 'UTC')
        _(time.zone).must_equal 'UTC'
      end
    end

    context "event only" do
      it "populates all attributes correctly" do
        subject = AIXM.time(:sunrise)
        _(subject.to_time).must_be :nil?
        _(subject.event).must_equal :sunrise
        _(subject.delta).must_equal 0
        _(subject.precedence).must_be :nil?
      end

      it "sets precedence to nil" do
        _(AIXM.time(:sunrise, whichever_comes: :first).precedence).must_be :nil?
      end

      it "accepts any valid event" do
        AIXM::Schedule::Time::EVENTS.each do |event|
          _(AIXM.time(event).event).must_equal event
        end
      end

      it "fails on invalid event" do
        _{ AIXM.time(:foobar) }.must_raise ArgumentError
      end

      it "fails on additional alternative event" do
        _{ AIXM.time(:sunrise, or: :sunset) }.must_raise ArgumentError
      end

      it "accepts event with delta" do
        _(AIXM.time(:sunrise, plus: 15).delta).must_equal 15
        _(AIXM.time(:sunrise, minus: 30).delta).must_equal(-30)
        _(AIXM.time(:sunrise, plus: 15, minus: 30).delta).must_equal(-15)
      end
    end

    context "time and alternative event" do
      it "populates all attributes correctly" do
        subject = AIXM.time('08:30', or: :sunrise)
        _(subject.to_time).must_equal Time.new(0, 1, 1, 8, 30, 0, 'UTC')
        _(subject.event).must_equal :sunrise
        _(subject.delta).must_equal 0
        _(subject.precedence).must_equal :first
      end

      it "accepts any valid alternative event" do
        AIXM::Schedule::Time::EVENTS.each do |event|
          _(AIXM.time('08:30', or: event).event).must_equal event
        end
      end

      it "accepts any valid precedence" do
        AIXM::Schedule::Time::PRECEDENCES.each do |precedence|
          _(AIXM.time('08:00', or: :sunrise, whichever_comes: precedence).precedence).must_equal precedence
        end
      end

      it "fails on invalid precedence" do
        _{ AIXM.time('08:00', or: :sunrise, whichever_comes: :foobar) }.must_raise ArgumentError
      end

      it "fails on valid time and event with undefined precedence" do
        _{ AIXM.time('08:00', or: :sunrise, whichever_comes: nil) }.must_raise ArgumentError
      end

      it "defaults to precedence :first" do
        _(AIXM.time('08:00', or: :sunrise).precedence).must_equal :first
      end
    end

    context "neither time nor event" do
      it "always fails" do
        _{ AIXM.time(plus: 15) }.must_raise ArgumentError
      end
    end
  end

  describe :to_s do
    it "returns human readable time only" do
      _(AIXM::Factory.time.to_s).must_equal '09:00 UTC'
    end

    it "returns human readable event only" do
      _(AIXM::Factory.event.to_s).must_equal 'sunrise'
    end

    it "returns human readable time and event" do
      _(AIXM.time('21:20', or: :sunset).to_s).must_equal "21:20 UTC or sunset whichever comes first"
      _(AIXM.time('21:20', or: :sunset, plus: 15).to_s).must_equal "21:20 UTC or sunset+15min whichever comes first"
      _(AIXM.time('21:20', or: :sunset, minus: 30).to_s).must_equal "21:20 UTC or sunset-30min whichever comes first"
      _(AIXM.time('21:20', or: :sunset, plus: 15, whichever_comes: :last).to_s).must_equal "21:20 UTC or sunset+15min whichever comes last"
    end

    it "applies given format" do
      _(AIXM::Factory.time.to_s('%H')).must_equal '09'
    end
  end

  describe :== do
    it "returns true for equal times" do
      _(AIXM.time('05:05')).must_equal AIXM.time('05:05')
      _(AIXM.time(:sunset)).must_equal AIXM.time(:sunset)
      _(AIXM.time('05:05', or: :sunset)).must_equal AIXM.time('05:05', or: :sunset)
    end

    it "returns false for different times" do
      _(AIXM.time('05:05')).wont_equal AIXM.time('15:15')
      _(AIXM.time(:sunset)).wont_equal AIXM.time('15:15')
      _(AIXM.time('05:05', or: :sunset)).wont_equal AIXM.time('05:05', or: :sunset, plus: 15)
    end
  end

  describe :sortable? do
    it "returns true for times without event" do
      _(AIXM::Factory.time).must_be :sortable?
    end

    it "returns false for times with event" do
      _(AIXM::Factory.time_with_event).wont_be :sortable?
    end
  end

  describe :in? do
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

    context "unsortable ranges with events" do
      it "accepts time and event in range" do
        _((AIXM.time('09:00')..AIXM.time(:sunset)))
        _((AIXM.time(:sunrise)..AIXM.time('21:00')))
        _((AIXM.time(:sunrise)..AIXM.time(:sunset)))
      end

      it "fails if subject is unsortable" do
        _{ AIXM::Factory.time_with_event.in?(AIXM.time('10:00')..AIXM.time('15:00')) }.must_raise RuntimeError
      end

      it "fails if range contains unsortable" do
        _{ AIXM::Factory.time.in?(AIXM.time('10:00', or: :sunrise)..AIXM.time('15:00')) }.must_raise RuntimeError
      end
    end
  end
end
