require_relative '../../../spec_helper'

describe AIXM::Component::Address do
  subject do
    AIXM::Factory.address
  end

  describe :initialize do
    it "fails for type :radio_frequency if address is no AIXM::F" do
      _{ AIXM.address(type: :radio_frequency, address: "foobar") }.must_raise ArgumentError
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _{ subject.type = :foobar }.must_raise ArgumentError
      _{ subject.type = nil }.must_raise ArgumentError
    end

    it "looks up valid values" do
      _(subject.tap { _1.type = :phone }.type).must_equal :phone
      _(subject.tap { _1.type = :RADIO }.type).must_equal :radio_frequency
    end
  end

  describe :address= do
    it "fails on invalid values" do
      _{ subject.address = nil }.must_raise ArgumentError
    end

    it "stringifies valid values for types other than :radio_frequency" do
      _(AIXM.address(type: :other, address: 123).address).must_equal '123'
    end
  end

  describe :address do
    it "returns AIXM::F for type :radio_frequency" do
      _(subject.tap { _1.type = :radio_frequency; _1.address = AIXM.f(123.45, :mhz) }.address).must_equal AIXM.f(123.45, :mhz)
    end

    it "returns String for all other types" do
      _(subject.tap { _1.type = :other; _1.address = 'foobar' }.address).must_equal 'foobar'
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
        <Xxx>
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
