require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::DesignatedPoint do
  subject do
    AIXM::Factory.designated_point
  end

  describe :type= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :type
    end

    it "looks up valid values" do
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
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [DesignatedPoint:ICAO] DESIGNATED POINT NAVAID -->
        <Dpn source="LF|GEN|0.0 FACTORY|0|0">
          <DpnUid>
            <codeId>DDD</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </DpnUid>
          <codeDatum>WGE</codeDatum>
          <codeType>ICAO</codeType>
          <txtName>DESIGNATED POINT NAVAID</txtName>
          <txtRmk>designated point navaid</txtRmk>
        </Dpn>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.name = subject.remarks = nil
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [DesignatedPoint:ICAO] UNNAMED -->
        <Dpn source="LF|GEN|0.0 FACTORY|0|0">
          <DpnUid>
            <codeId>DDD</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </DpnUid>
          <codeDatum>WGE</codeDatum>
          <codeType>ICAO</codeType>
        </Dpn>
      END
    end
  end
end
