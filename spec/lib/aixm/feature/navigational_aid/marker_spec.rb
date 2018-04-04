require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::Marker do
  subject do
    AIXM::Factory.marker
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
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
    it "must build correct OFMX" do
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
  end
end
