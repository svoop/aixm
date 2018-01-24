require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::NDB do
  describe :initialize do
    let :f do
      AIXM.f(555, :KHZ)
    end

    it "won't accept invalid arguments" do
      -> { AIXM.ndb(id: 'N', name: 'NDB', xy: AIXM::Factory.xy, f: 0) }.must_raise ArgumentError
    end
  end

  context "complete" do
    subject do
      AIXM::Factory.ndb
    end

    describe :kind do
      it "must return class or type" do
        subject.kind.must_equal :NDB
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 251142755
      end
    end

    describe :to_xml do
      it "must build correct XML with OFM extension" do
        subject.to_xml(:ofm).must_equal <<~END
          <!-- Navigational aid: [NDB] NDB NAVAID -->
          <Ndb>
            <NdbUid newEntity="true">
              <codeId>NDB</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </NdbUid>
            <OrgUid/>
            <txtName>NDB NAVAID</txtName>
            <valFreq>555</valFreq>
            <uomFreq>KHZ</uomFreq>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <txtRmk>ndb navaid</txtRmk>
          </Ndb>
        END
      end
    end
  end
end
