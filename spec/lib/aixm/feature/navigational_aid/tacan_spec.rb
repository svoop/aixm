require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::TACAN do
  context "complete" do
    subject do
      AIXM::Factory.tacan
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal "TACAN"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 518546211
      end
    end

    describe :to_xml do
      it "must build correct XML with OFM extension" do
        subject.to_xml(:ofm).must_equal <<~END
          <!-- Navigational aid: [TACAN] TACAN NAVAID -->
          <Tcn>
            <TcnUid newEntity="true">
              <codeId>TCN</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </TcnUid>
            <OrgUid/>
            <txtName>TACAN NAVAID</txtName>
            <codeChannel>29X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ttt>
              <codeWorkHr>H24</codeWorkHr>
            </Ttt>
            <txtRmk>tacan navaid</txtRmk>
          </Tcn>
        END
      end
    end
  end
end
