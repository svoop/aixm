require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::VOR do
  context "VOR" do
    subject do
      AIXM::Factory.vor
    end

    describe :type= do
      it "fails on invalid values" do
        _([nil, :foobar, 123]).wont_be_written_to subject, :type
      end

      it "looks up valid values" do
        _(subject.tap { _1.type = :conventional }.type).must_equal :conventional
        _(subject.tap { _1.type = :DVOR }.type).must_equal :doppler
      end
    end

    describe :f= do
      it "fails on invalid values" do
        _([nil, :foobar, 123]).wont_be_written_to subject, :f
      end

      it "accepts valid values" do
        _([AIXM.f(110, :mhz)]).must_be_written_to subject, :f
      end
    end

    describe :north= do
      it "fails on invalid values" do
        _([nil, :foobar, 123]).wont_be_written_to subject, :north
      end

      it "looks up valid values" do
        _(subject.tap { _1.north = :magnetic }.north).must_equal :magnetic
        _(subject.tap { _1.north = :TRUE }.north).must_equal :geographic
      end
    end

    describe :kind do
      it "must return class/type combo" do
        _(subject.kind).must_equal "VOR:VOR"
      end
    end

    describe :to_xml do
      it "builds correct complete OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VVV / VOR NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
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

      it "builds correct minimal OFMX" do
        AIXM.ofmx!
        subject.name = subject.z = subject.timetable = subject.remarks = nil
        _(subject.to_xml).must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VVV -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
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
        vor.associate_dme
      end
    end

    describe :kind do
      it "must return class/type combo" do
        _(subject.kind).must_equal "VOR:VOR"
      end
    end

    describe :associate_dme do
      it "returns the DME" do
        _(subject.associate_dme).must_be_instance_of AIXM::Feature::NavigationalAid::DME
      end

      it "must set the correct channel" do
        _(subject.f).must_equal AIXM.f(111, :mhz)
        _(subject.dme.channel).must_equal '47X'
      end
    end

    describe :to_xml do
      it "builds correct OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VVV / VOR/DME NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
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
          <!-- NavigationalAid: [DME] VVV / VOR/DME NAVAID -->
          <Dme source="LF|GEN|0.0 FACTORY|0|0">
            <DmeUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeChannel>47X</codeChannel>
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
        vor.associate_tacan
      end
    end

    describe :kind do
      it "must return class/type combo" do
        _(subject.kind).must_equal "VOR:VOR"
      end
    end

    describe :associate_tacan do
      it "returns the TACAN" do
        _(subject.associate_tacan).must_be_instance_of AIXM::Feature::NavigationalAid::TACAN
      end

      it "must set the correct channel" do
        _(subject.f).must_equal AIXM.f(111, :mhz)
        _(subject.tacan.channel).must_equal '47X'
      end
    end

    describe :to_xml do
      it "builds correct OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~END
          <!-- NavigationalAid: [VOR:VOR] VVV / VORTAC NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
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
          <!-- NavigationalAid: [TACAN] VVV / VORTAC NAVAID -->
          <Tcn source="LF|GEN|0.0 FACTORY|0|0">
            <TcnUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </TcnUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeChannel>47X</codeChannel>
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
