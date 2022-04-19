require_relative '../../../spec_helper'

describe AIXM::Component::Timesheet do
  subject do
    AIXM::Factory.timesheet
  end

  describe :adjust_to_dst= do
    it "fails on invalid values" do
      _([nil, 'N', 0]).wont_be_written_to subject, :adjust_to_dst
    end
  end

  describe :adjust_to_dst? do
    it "returns true when adjustable" do
      _(subject).must_be :adjust_to_dst?
    end

    it "returns false when not adjustable" do
      _(subject.tap { _1.adjust_to_dst = false }).wont_be :adjust_to_dst?
    end
  end

  describe :dates= do
    it "accepts valid values" do
      values = [
        (AIXM::Factory.date..AIXM::Factory.date),
        (AIXM::Factory.yearless_date..AIXM::Factory.yearless_date)
      ]
      _(values).must_be_written_to subject, :dates
    end

    it "fails on invalid values" do
      _([AIXM::Factory.date, 123, :foobar, nil]).wont_be_written_to subject, :dates
    end
  end

  describe :day= do
    it "accepts valid values" do
      [AIXM::Factory.day, AIXM::Factory.special_day].each do |value|
        _(subject.tap { _1.day = value }.day).must_equal value
      end
    end

    it "fails on invalid values" do
      [123, :foobar, nil].each do |value|
        _{ subject.day = value }.must_raise ArgumentError
      end
    end
  end

  describe :days= do
    it "accepts valid values" do
      values = [
        (AIXM::Factory.day..AIXM::Factory.day),
        (AIXM::Factory.special_day..AIXM::Factory.special_day)
      ]
      _(values).must_be_written_to subject, :days
    end

    it "fails on invalid values" do
      _([123, :foobar, nil]).wont_be_written_to subject, :days
    end
  end

  describe :times= do
    it "accepts valid values" do
      values = [
        nil,
        (AIXM::Factory.time..AIXM::Factory.time),
        (AIXM::Factory.time_with_event..AIXM::Factory.time_with_event)
      ]
      _(values).must_be_written_to subject, :times
    end

    it "fails on invalid values" do
      _([AIXM::Factory.time, 123, :foobar]).wont_be_written_to subject, :times
    end
  end

  describe :xml do
    it "builds correct OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <Timsh>
          <codeTimeRef>UTCW</codeTimeRef>
          <dateValidWef>01-03</dateValidWef>
          <dateYearValidWef>2022</dateYearValidWef>
          <dateValidTil>22-03</dateValidTil>
          <dateYearValidTil>2022</dateYearValidTil>
          <codeDay>TUE</codeDay>
          <codeDayTil>THU</codeDayTil>
          <timeWef>09:00</timeWef>
          <timeTil>21:20</timeTil>
          <codeEventTil>SS</codeEventTil>
          <timeRelEventTil>15</timeRelEventTil>
          <codeCombTil>L</codeCombTil>
        </Timsh>
      END
    end

    it "builds correct complete AIXM" do
      _(subject.to_xml).must_equal <<~END
        <Timsh>
          <codeTimeRef>UTCW</codeTimeRef>
          <dateValidWef>01-03</dateValidWef>
          <dateValidTil>22-03</dateValidTil>
          <codeDay>TUE</codeDay>
          <codeDayTil>THU</codeDayTil>
          <timeWef>09:00</timeWef>
          <timeTil>21:20</timeTil>
          <codeEventTil>SS</codeEventTil>
          <timeRelEventTil>15</timeRelEventTil>
          <codeCombTil>L</codeCombTil>
        </Timsh>
      END
    end

    it "builds correct minimal AIXM" do
      subject.adjust_to_dst = false
      subject.day = AIXM::ANY_DAY
      subject.times = nil
      _(subject.to_xml).must_equal <<~END
        <Timsh>
          <codeTimeRef>UTC</codeTimeRef>
          <dateValidWef>01-03</dateValidWef>
          <dateValidTil>22-03</dateValidTil>
          <codeDay>ANY</codeDay>
        </Timsh>
      END
    end
  end
end
