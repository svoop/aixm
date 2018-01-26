require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::DesignatedPoint do
  context "complete" do
    subject do
      AIXM::Factory.designated_point
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal "DesignatedPoint:ICAO"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 5317882
      end
    end

    describe :to_xml do
      it "must build correct XML of VOR with OFM extension" do
        subject.to_xml(:ofm).must_equal <<~END
          <!-- Navigational aid: [DesignatedPoint:ICAO] DESIGNATED POINT NAVAID -->
          <Dpn>
            <DpnUid newEntity="true">
              <codeId>DDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </DpnUid>
            <OrgUid/>
            <txtName>DESIGNATED POINT NAVAID</txtName>
            <codeDatum>WGE</codeDatum>
            <codeType>ICAO</codeType>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>designated point navaid</txtRmk>
          </Dpn>
        END
      end
    end
  end
end
