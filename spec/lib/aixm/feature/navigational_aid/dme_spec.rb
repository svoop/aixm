require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::DME do
  subject do
    AIXM::Factory.dme
  end

  describe :organisation= do
    macro :organisation
  end

  describe :channel= do
    it "fails on invalid values" do
      -> { subject.channel = 123 }.must_raise ArgumentError
    end

    it "upcases value" do
      subject.tap { |s| s.channel = '3x' }.channel.must_equal '3X'
    end
  end

  describe :kind do
    it "must return class/type combo" do
      subject.kind.must_equal "DME"
    end
  end

  describe :to_xml do
    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [DME] DME NAVAID -->
        <Dme source="LF|GEN|0.0 FACTORY|0|0">
          <DmeUid region="LF">
            <codeId>MMM</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </DmeUid>
          <OrgUid region=\"LF\">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <txtName>DME NAVAID</txtName>
          <codeChannel>95X</codeChannel>
          <codeDatum>WGE</codeDatum>
          <valElev>500</valElev>
          <uomDistVer>FT</uomDistVer>
          <Dtt>
            <codeWorkHr>H24</codeWorkHr>
          </Dtt>
          <txtRmk>dme navaid</txtRmk>
        </Dme>
      END
    end
  end
end
