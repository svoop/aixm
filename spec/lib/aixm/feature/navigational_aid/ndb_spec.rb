require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::NDB do
  subject do
    AIXM::Factory.ndb
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.type = :en_route }.type.must_equal :en_route
      subject.tap { |s| s.type = :L }.type.must_equal :locator
    end
  end

  describe :f= do
    it "fails on invalid values" do
      -> { subject.f = :foobar }.must_raise ArgumentError
      -> { subject.f = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.f = AIXM.f(200, :khz) }.f.freq.must_equal 200
    end
  end

  describe :kind do
    it "must return class/type combo" do
      subject.kind.must_equal "NDB:B"
    end
  end

  describe :to_xml do
    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [NDB:B] NDB NAVAID -->
        <Ndb source="LF|GEN|0.0 FACTORY|0|0">
          <NdbUid region="LF">
            <codeId>NNN</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
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
