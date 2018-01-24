require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::VOR do
  describe :initialize do
    let :f do
      AIXM.f(111, :MHZ)
    end

    it "won't accept invalid arguments" do
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :foo, f: f, north: :geographic) }.must_raise ArgumentError
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :vor, f: 0, north: :geographic) }.must_raise ArgumentError
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :vor, f: f, north: :foobar) }.must_raise ArgumentError
    end
  end

  context "complete" do
    subject do
      AIXM::Factory.vor
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal :VOR
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 688826460
      end
    end

    describe :to_xml do
      it "must build correct XML of VOR with OFM extension" do
        subject.to_xml(:OFM).must_equal <<~END
          <!-- Navigational aid: [VOR] VOR NAVAID -->
          <Vor>
            <VorUid newEntity="true">
              <codeId>VOR</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </VorUid>
            <OrgUid/>
            <txtName>VOR NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <txtRmk>vor navaid</txtRmk>
          </Vor>
        END
      end
    end
  end
end
