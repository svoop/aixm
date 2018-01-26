require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::VOR do
  describe :initialize do
    let :f do
      AIXM.f(111, :mhz)
    end

    it "won't accept invalid arguments" do
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :foo, f: f, north: :geographic) }.must_raise ArgumentError
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :vor, f: 0, north: :geographic) }.must_raise ArgumentError
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :vor, f: f, north: :foobar) }.must_raise ArgumentError
    end
  end

  context "complete VOR" do
    subject do
      AIXM::Factory.vor
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 152119936
      end
    end

    describe :to_xml do
      it "must build correct XML of VOR with OFM extension" do
        subject.to_xml(:ofm).must_equal <<~END
          <!-- Navigational aid: [VOR:VOR] VOR NAVAID -->
          <Vor>
            <VorUid newEntity="true">
              <codeId>VVV</codeId>
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
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor navaid</txtRmk>
          </Vor>
        END
      end
    end
  end

  context "complete VOR/DME" do
    subject do
      AIXM::Factory.vor.tap do |vor|
        vor.name = "VOR/DME NAVAID"
        vor.remarks = "vor/dme navaid"
        vor.associate_dme(channel: '84X')
      end
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 863096858
      end
    end

    describe :to_xml do
      it "must build correct XML of VOR with OFM extension" do
        subject.to_xml(:ofm).must_equal <<~END
          <!-- Navigational aid: [VOR:VOR] VOR/DME NAVAID -->
          <Vor>
            <VorUid newEntity="true">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </VorUid>
            <OrgUid/>
            <txtName>VOR/DME NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Vor>
          <!-- Navigational aid: [DME] VOR/DME NAVAID -->
          <Dme>
            <DmeUid newEntity="true">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </DmeUid>
            <OrgUid/>
            <VorUid newEntity="true">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </VorUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeChannel>84X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Dme>
        END
      end
    end
  end

  context "complete VORTAC" do
    subject do
      AIXM::Factory.vor.tap do |vor|
        vor.name = "VORTAC NAVAID"
        vor.remarks = "vortac navaid"
        vor.associate_tacan(channel: '54X')
      end
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 458371299
      end
    end

    describe :to_xml do
      it "must build correct XML of VOR with OFM extension" do
        subject.to_xml(:ofm).must_equal <<~END
          <!-- Navigational aid: [VOR:VOR] VORTAC NAVAID -->
          <Vor>
            <VorUid newEntity="true">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </VorUid>
            <OrgUid/>
            <txtName>VORTAC NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vortac navaid</txtRmk>
          </Vor>
          <!-- Navigational aid: [TACAN] VORTAC NAVAID -->
          <Tcn>
            <TcnUid newEntity="true">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </TcnUid>
            <OrgUid/>
            <VorUid newEntity="true">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </VorUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeChannel>54X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ttt>
              <codeWorkHr>H24</codeWorkHr>
            </Ttt>
            <txtRmk>vortac navaid</txtRmk>
          </Tcn>
        END
      end
    end
  end
end
