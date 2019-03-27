require_relative '../../../spec_helper'

describe AIXM::Component::Address do
  subject do
    AIXM::Factory.address
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "looks up valid values" do
      subject.tap { |s| s.type = :phone }.type.must_equal :phone
      subject.tap { |s| s.type = :RADIO }.type.must_equal :radio_frequency
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :xml= do
    it "builds correct OFMX" do
      AIXM.ofmx!
      subject.to_xml(as: :Xxx, sequence: 1).must_equal <<~END
        <Xxx>
          <XxxUid>
            <codeType>RADIO</codeType>
            <noSeq>1</noSeq>
          </XxxUid>
          <txtAddress>123.35</txtAddress>
          <txtRmk>A/A</txtRmk>
        </Xxx>
      END
    end

    it "builds correct AIXM" do
      AIXM.aixm!
      subject = AIXM.address(type: :weather_url, address: 'https://www.foo.bar')
      subject.to_xml(as: :Xxx, sequence: 1).must_equal <<~END
        <Xxx>
          <XxxUid>
            <codeType>URL</codeType>
            <noSeq>1</noSeq>
          </XxxUid>
          <txtAddress>https://www.foo.bar</txtAddress>
        </Xxx>
      END
    end
  end
end