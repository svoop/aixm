require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::Marker do
  subject do
    AIXM::Factory.marker
  end

  describe :type= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :type
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :name
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.type = :middle }.type).must_equal :middle
      _(subject.tap { |s| s.type = :O }.type).must_equal :outer
    end
  end

  describe :kind do
    it "must return class/type combo" do
      _(subject.kind).must_equal "Marker:O"
    end
  end

  describe :to_xml do
    macro :mid

    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- NavigationalAid: [Marker:O] --- / MARKER NAVAID -->
        <Mkr source="LF|GEN|0.0 FACTORY|0|0">
          <MkrUid>
            <codeId>---</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </MkrUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codePsnIls>O</codePsnIls>
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

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.type = subject.name = subject.z = subject.timetable = subject.remarks = nil
      _(subject.to_xml).must_equal <<~END
        <!-- NavigationalAid: [Marker] --- -->
        <Mkr source="LF|GEN|0.0 FACTORY|0|0">
          <MkrUid>
            <codeId>---</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </MkrUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <valFreq>75</valFreq>
          <uomFreq>MHZ</uomFreq>
          <codeDatum>WGE</codeDatum>
        </Mkr>
      END
    end

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid = true
      AIXM.config.region = 'LF'
      _(subject.to_xml).must_match /<MkrUid mid="f3463c39-b380-d31f-b42a-5dfa0b4edb12">/
    end
  end
end
