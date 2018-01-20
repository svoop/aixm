require_relative '../../spec_helper'

describe AIXM::Schedule do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM::Schedule.new(code: 'foobar') }.must_raise ArgumentError
    end

    it "must accept explicit codes" do
      AIXM::Schedule.new(code: :sunrise_to_sunset).code.must_equal :HJ
    end

    it "must accept short codes" do
      AIXM::Schedule.new(code: :H24).code.must_equal :H24
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM::Schedule.new(code: :H24)
      subject.to_digest.must_equal 962036587
    end
  end

  describe :to_xml do
    it "must build correct XML" do
      subject = AIXM::Schedule.new(code: :H24)
      subject.to_xml.must_equal <<~END
        <codeWorkHr>H24</codeWorkHr>
      END
    end
  end
end
