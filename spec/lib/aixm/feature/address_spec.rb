require_relative '../../../spec_helper'

describe AIXM::Feature::Address do
  subject do
    AIXM::Factory.address
  end

  describe :type= do
    it "fails on invalid values" do
      _{ subject.type = :foobar }.must_raise ArgumentError
      _{ subject.type = nil }.must_raise ArgumentError
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.type = :phone }.type).must_equal :phone
      _(subject.tap { |s| s.type = :RADIO }.type).must_equal :radio_frequency
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct OFMX" do
      AIXM.ofmx!
      _(subject.to_xml(as: :Xxx, sequence: 1)).must_equal <<~END
        <!-- Address: RADIO -->
        <Xxx source="LF|GEN|0.0 FACTORY|0|0">
          <XxxUid>
            <codeType>RADIO</codeType>
            <noSeq>1</noSeq>
          </XxxUid>
          <txtAddress>123.35</txtAddress>
          <txtRmk>A/A (callsign PUJAUT)</txtRmk>
        </Xxx>
      END
    end

    it "builds correct AIXM" do
      subject = AIXM.address(type: :weather_url, address: 'https://www.foo.bar')
      _(subject.to_xml(as: :Xxx, sequence: 1)).must_equal <<~END
        <!-- Address: URL-MET -->
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
