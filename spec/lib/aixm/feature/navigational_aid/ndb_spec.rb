require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::NDB do
  subject do
    AIXM::Factory.ndb
  end

  describe :type= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :type
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :type
    end

    it "looks up valid values" do
      subject.tap { |s| s.type = :en_route }.type.must_equal :en_route
      subject.tap { |s| s.type = :L }.type.must_equal :locator
    end
  end

  describe :f= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :f
    end

    it "accepts valid values" do
      [AIXM.f(200, :khz)].must_be_written_to subject, :f
    end
  end

  describe :kind do
    it "must return class/type combo" do
      subject.kind.must_equal "NDB:B"
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [NDB:B] NDB NAVAID -->
        <Ndb source="LF|GEN|0.0 FACTORY|0|0">
          <NdbUid region="LF">
            <codeId>NNN</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </NdbUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
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

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.name = subject.type = subject.z = subject.schedule = subject.remarks = nil
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [NDB] UNNAMED -->
        <Ndb source="LF|GEN|0.0 FACTORY|0|0">
          <NdbUid region="LF">
            <codeId>NNN</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </NdbUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <valFreq>555</valFreq>
          <uomFreq>KHZ</uomFreq>
          <codeDatum>WGE</codeDatum>
        </Ndb>
      END
    end
  end
end
