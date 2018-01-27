require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::DME do
  context "complete" do
    subject do
      AIXM::Factory.dme
    end

    let :digest do
      subject.to_digest
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal "DME"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 537506748
      end
    end

    describe :to_aixm do
      it "must build correct XML with OFM extension" do
        subject.to_aixm(:ofm).must_equal <<~END
          <!-- NavigationalAid: [DME] DME NAVAID -->
          <Dme>
            <DmeUid mid="#{digest}" newEntity="true">
              <codeId>MMM</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </DmeUid>
            <OrgUid/>
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
end
