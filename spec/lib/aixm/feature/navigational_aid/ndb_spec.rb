require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::NDB do
  describe :initialize do
    let :f do
      AIXM.f(555, :khz)
    end

    it "won't accept invalid arguments" do
      -> { AIXM.ndb(id: 'N', name: 'NDB', xy: AIXM::Factory.xy, type: :foo, f: f) }.must_raise ArgumentError
      -> { AIXM.ndb(id: 'N', name: 'NDB', xy: AIXM::Factory.xy, type: :en_route, f: 0) }.must_raise ArgumentError
    end
  end

  context "complete en-route NDB" do
    subject do
      AIXM::Factory.ndb
    end

    let :digest do
      subject.to_digest
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "NDB:B"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 782114926
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [NDB:B] NDB NAVAID -->
          <Ndb>
            <NdbUid mid="#{digest}">
              <codeId>NNN</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </NdbUid>
            <OrgUid/>
            <txtName>NDB NAVAID</txtName>
            <valFreq>555</valFreq>
            <uomFreq>KHZ</uomFreq>
            <codeClass>B</codeClass>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ntt>
              <codeWorkHr>H24</codeWorkHr>
            </Ntt>
            <txtRmk>ndb navaid</txtRmk>
          </Ndb>
        END
      end
    end
  end

  context "complete locator NDB" do
    subject do
      AIXM::Factory.ndb.tap do |ndb|
        ndb.type = :locator
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "NDB:L"
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_match %r(<codeClass>L</codeClass>)
      end
    end
  end

  context "complete marine NDB" do
    subject do
      AIXM::Factory.ndb.tap do |ndb|
        ndb.type = :marine
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "NDB:M"
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_match %r(<codeClass>M</codeClass>)
      end
    end
  end
end
