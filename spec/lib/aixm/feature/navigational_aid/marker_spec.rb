require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::Marker do
  context "complete" do
    subject do
      AIXM::Factory.marker
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal "Marker"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 371155747
      end
    end

    describe :to_aixm do
      it "must build correct XML with OFM extension" do
        subject.to_aixm(:ofm).must_equal <<~END
          <!-- NavigationalAid: [Marker] MARKER NAVAID -->
          <Mkr>
            <MkrUid newEntity="true">
              <codeId>---</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </MkrUid>
            <OrgUid/>
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
end
