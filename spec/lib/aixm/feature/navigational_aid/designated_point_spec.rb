require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::DesignatedPoint do
  subject do
    AIXM::Factory.designated_point
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.type = :icao }.type.must_equal :icao
      subject.tap { |s| s.type = :OTHER }.type.must_equal :other
    end
  end

  describe :kind do
    it "must return class/type combo" do
      subject.kind.must_equal "DesignatedPoint:ICAO"
    end
  end

  describe :to_xml do
    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [DesignatedPoint:ICAO] DESIGNATED POINT NAVAID -->
        <Dpn source="LF|GEN|0.0 FACTORY|0|0">
          <DpnUid region="LF">
            <codeId>DDD</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </DpnUid>
          <OrgUid/>
          <txtName>DESIGNATED POINT NAVAID</txtName>
          <codeDatum>WGE</codeDatum>
          <codeType>ICAO</codeType>
          <valElev>500</valElev>
          <uomDistVer>FT</uomDistVer>
          <txtRmk>designated point navaid</txtRmk>
        </Dpn>
      END
    end
  end
end
