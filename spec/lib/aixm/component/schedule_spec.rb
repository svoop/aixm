require_relative '../../../spec_helper'

describe AIXM::Component::Schedule do
  subject do
    AIXM::Factory.schedule
  end

  describe :code= do
    it "fails on invalid values" do
      -> { subject.code = :foobar }.must_raise ArgumentError
      -> { subject.code = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.code = :notam }.code.must_equal :notam
      subject.tap { |s| s.code = :H24 }.code.must_equal :continuous
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "must build correct AIXM" do
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Timetable>
          <codeWorkHr>HJ</codeWorkHr>
          <txtRmkWorkHr>schedule remarks</txtRmkWorkHr>
        </Timetable>
      END
    end

    it "must build with arbitrary tag" do
      subject.to_xml.must_match(/<Timetable>/)
      subject.to_xml(as: :FooBar).must_match(/<FooBar>/)
    end
  end
end
