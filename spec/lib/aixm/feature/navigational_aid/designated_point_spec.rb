require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::DesignatedPoint do
  subject do
    AIXM::Factory.designated_point
  end

  describe :type= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.type = :icao }.type).must_equal :icao
      _(subject.tap { |s| s.type = :'VFR-RP' }.type).must_equal :vfr_reporting_point
    end
  end

  describe :kind do
    it "must return class/type combo" do
      _(subject.kind).must_equal "DesignatedPoint:VFR-RP"
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- NavigationalAid: [DesignatedPoint:VFR-RP] DDD / DESIGNATED POINT NAVAID -->
        <Dpn source="LF|GEN|0.0 FACTORY|0|0">
          <DpnUid region="LF">
            <codeId>DDD</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </DpnUid>
          <AhpUidAssoc region="LF">
            <codeId>LFNT</codeId>
          </AhpUidAssoc>
          <codeDatum>WGE</codeDatum>
          <codeType>VFR-RP</codeType>
          <txtName>DESIGNATED POINT NAVAID</txtName>
          <txtRmk>designated point navaid</txtRmk>
        </Dpn>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.name = subject.remarks = nil
      _(subject.to_xml).must_equal <<~END
        <!-- NavigationalAid: [DesignatedPoint:VFR-RP] DDD -->
        <Dpn source="LF|GEN|0.0 FACTORY|0|0">
          <DpnUid region="LF">
            <codeId>DDD</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </DpnUid>
          <AhpUidAssoc region="LF">
            <codeId>LFNT</codeId>
          </AhpUidAssoc>
          <codeDatum>WGE</codeDatum>
          <codeType>VFR-RP</codeType>
        </Dpn>
      END
    end

    it "builds correct complete AIXM" do
      _(subject.to_xml).must_equal <<~END
        <!-- NavigationalAid: [DesignatedPoint:VFR-RP] DDD / DESIGNATED POINT NAVAID -->
        <Dpn>
          <DpnUid>
            <codeId>DDD</codeId>
            <geoLat>475133.00N</geoLat>
            <geoLong>0073336.00E</geoLong>
          </DpnUid>
          <AhpUidAssoc>
            <codeId>LFNT</codeId>
          </AhpUidAssoc>
          <codeDatum>WGE</codeDatum>
          <codeType>OTHER</codeType>
          <txtName>DESIGNATED POINT NAVAID</txtName>
          <txtRmk>designated point navaid</txtRmk>
        </Dpn>
      END
    end
  end
end
