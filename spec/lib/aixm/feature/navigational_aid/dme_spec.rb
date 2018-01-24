require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::DME do
  context "complete" do
    subject do
      AIXM::Factory.dme
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal :DME
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 398427059
      end
    end

    describe :to_xml do
      it "must build correct XML with OFM extension" do
        subject.to_xml(:ofm).must_equal <<~END
          <!-- Navigational aid: [DME] DME NAVAID -->
          <Dme>
            <DmeUid newEntity="true">
              <codeId>DME</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </DmeUid>
            <OrgUid/>
            <txtName>DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <txtRmk>dme navaid</txtRmk>
          </Dme>
        END
      end
    end
  end
end
