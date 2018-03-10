require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::VOR do
  describe :initialize do
    let :f do
      AIXM.f(111, :mhz)
    end

    it "won't accept invalid arguments" do
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :foo, f: f, north: :geographic) }.must_raise ArgumentError
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :conventional, f: 0, north: :geographic) }.must_raise ArgumentError
      -> { AIXM.vor(id: 'V', name: 'VOR', xy: AIXM::Factory.xy, type: :conventional, f: f, north: :foobar) }.must_raise ArgumentError
    end
  end

  context "complete conventional VOR" do
    subject do
      AIXM::Factory.vor
    end

    let :digest do
      subject.to_digest
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 904391566
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VOR NAVAID -->
          <Vor>
            <VorUid mid="#{digest}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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

  context "complete Doppler VOR" do
    subject do
      AIXM::Factory.vor.tap do |vor|
        vor.type = :doppler
      end
    end

    let :digest do
      subject.to_digest
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "VOR:DVOR"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 293163781
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [VOR:DVOR] VOR NAVAID -->
          <Vor>
            <VorUid mid="#{digest}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid/>
            <txtName>VOR NAVAID</txtName>
            <codeType>DVOR</codeType>
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

    let :digests do
      [subject.to_digest, subject.dme.to_digest]
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 604205702
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VOR/DME NAVAID -->
          <Vor>
            <VorUid mid="#{digests.first}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
          <!-- NavigationalAid: [DME] VOR/DME NAVAID -->
          <Dme>
            <DmeUid mid="#{digests.last}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid/>
            <VorUid mid="#{digests.first}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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

    let :digests do
      [subject.to_digest, subject.tacan.to_digest]
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 339710051
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VORTAC NAVAID -->
          <Vor>
            <VorUid mid="#{digests.first}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
          <!-- NavigationalAid: [TACAN] VORTAC NAVAID -->
          <Tcn>
            <TcnUid mid="#{digests.last}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </TcnUid>
            <OrgUid/>
            <VorUid mid="#{digests.first}">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
