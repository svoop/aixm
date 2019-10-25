require_relative '../../../spec_helper'

describe AIXM::Component::Timetable do
  subject do
    AIXM::Factory.timetable
  end

  describe :code= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :code
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.code = :notam }.code).must_equal :notam
      _(subject.tap { |s| s.code = :H24 }.code).must_equal :continuous
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
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
end
