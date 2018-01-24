require_relative '../../../spec_helper'

describe AIXM::Component::Schedule do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM.schedule(code: 'foobar') }.must_raise ArgumentError
    end

    it "must accept explicit codes" do
      AIXM.schedule(code: :sunrise_to_sunset).code.must_equal :sunrise_to_sunset
    end

    it "must accept short codes" do
      AIXM.schedule(code: :H24).code.must_equal :continuous
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM.schedule(code: :continuous)
      subject.to_digest.must_equal 349179367
    end
  end

  describe :to_xml do
    it "must build correct XML" do
      subject = AIXM.schedule(code: :continuous)
      subject.to_xml.must_equal <<~END
        <codeWorkHr>H24</codeWorkHr>
      END
    end
  end
end
