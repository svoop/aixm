require_relative '../../../spec_helper'

describe AIXM::Component::Timetable do
  subject do
    AIXM::Factory.timetable
  end

  describe :code= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :code
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :code
    end

    it "looks up valid values" do
      _(subject.tap { _1.code = :notam }.code).must_equal :notam
      _(subject.tap { _1.code = :H24 }.code).must_equal :continuous
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    context "predefined code" do
      it "builds correct complete AIXM" do
        _(subject.to_xml).must_equal <<~END
          <Timetable>
            <codeWorkHr>HJ</codeWorkHr>
            <txtRmkWorkHr>timetable remarks</txtRmkWorkHr>
          </Timetable>
        END
      end

      it "builds correct minimal AIXM" do
        subject.remarks = nil
        _(subject.to_xml).must_equal <<~END
          <Timetable>
            <codeWorkHr>HJ</codeWorkHr>
          </Timetable>
        END
      end

      it "builds with arbitrary tag" do
        _(subject.to_xml).must_match(/<Timetable>/)
        _(subject.to_xml(as: :FooBar)).must_match(/<FooBar>/)
      end
    end

    context "one timesheet" do
      subject do
        AIXM::Factory.timetable_with_timesheet
      end

      it "builds correct OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~END
          <Timetable>
            <codeWorkHr>TIMSH</codeWorkHr>
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
          </Timetable>
        END
      end
    end

    context "multiple timesheets" do
      subject do
        AIXM::Factory.timetable_with_timesheet
      end

      it "builds correct OFMX" do
        subject.add_timesheet(AIXM::Factory.timesheet)
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~END
          <Timetable>
            <codeWorkHr>TIMSH</codeWorkHr>
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
          </Timetable>
        END
      end
    end
  end
end
