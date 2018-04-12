require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::Marker do
  subject do
    AIXM::Factory.marker
  end

  describe :type= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :type
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :name
    end

    it "looks up valid values" do
      subject.tap { |s| s.type = :middle }.type.must_equal :middle
      subject.tap { |s| s.type = :O }.type.must_equal :outer
    end
  end

  describe :kind do
    it "must return class/type combo" do
      subject.kind.must_equal "Marker:O"
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [Marker:O] MARKER NAVAID -->
        <Mkr source="LF|GEN|0.0 FACTORY|0|0">
          <MkrUid region="LF">
            <codeId>---</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </MkrUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codePsnIls>O</codePsnIls>
          <valFreq>75</valFreq>
          <uomFreq>MHZ</uomFreq>
          <txtName>MARKER NAVAID</txtName>
          <codeDatum>WGE</codeDatum>
          <valElev>500</valElev>
          <uomDistVer>FT</uomDistVer>
          <Mtt>
            <codeWorkHr>H24</codeWorkHr>
          </Mtt>
          <txtRmk>marker navaid</txtRmk>
        </Mkr>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.type = subject.name = subject.z = subject.timetable = subject.remarks = nil
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [Marker] UNNAMED -->
        <Mkr source="LF|GEN|0.0 FACTORY|0|0">
          <MkrUid region="LF">
            <codeId>---</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </MkrUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <valFreq>75</valFreq>
          <uomFreq>MHZ</uomFreq>
          <codeDatum>WGE</codeDatum>
        </Mkr>
      END
    end
  end
end
