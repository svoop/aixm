require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::VOR do
  context "VOR" do
    subject do
      AIXM::Factory.vor
    end

    describe :type= do
      it "fails on invalid values" do
        -> { subject.type = :foobar }.must_raise ArgumentError
        -> { subject.type = nil }.must_raise ArgumentError
      end

      it "accepts valid values" do
        subject.tap { |s| s.type = :conventional }.type.must_equal :conventional
        subject.tap { |s| s.type = :DVOR }.type.must_equal :doppler
      end
    end

    describe :f= do
      it "fails on invalid values" do
        -> { subject.f = :foobar }.must_raise ArgumentError
        -> { subject.f = nil }.must_raise ArgumentError
      end

      it "accepts valid values" do
        subject.tap { |s| s.f = AIXM.f(110, :mhz) }.f.freq.must_equal 110
      end
    end

    describe :north= do
      it "fails on invalid values" do
        -> { subject.north = :foobar }.must_raise ArgumentError
        -> { subject.north = nil }.must_raise ArgumentError
      end

      it "accepts valid values" do
        subject.tap { |s| s.north = :magnetic }.north.must_equal :magnetic
        subject.tap { |s| s.north = :TRUE }.north.must_equal :geographic
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VOR NAVAID -->
          <Vor>
            <VorUid region="LF">
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

  context "VOR/DME" do
    subject do
      AIXM::Factory.vor.tap do |vor|
        vor.name = "VOR/DME NAVAID"
        vor.remarks = "vor/dme navaid"
        vor.associate_dme(channel: '84X')
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VOR/DME NAVAID -->
          <Vor>
            <VorUid region="LF">
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
            <DmeUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid/>
            <VorUid region="LF">
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

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "VOR:VOR"
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VORTAC NAVAID -->
          <Vor>
            <VorUid region="LF">
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
            <TcnUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </TcnUid>
            <OrgUid/>
            <VorUid region="LF">
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
