require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::TACAN do
  subject do
    AIXM::Factory.tacan
  end

  describe :channel= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :channel
    end

    it "upcases value" do
      subject.tap { |s| s.channel = '3x' }.channel.must_equal '3X'
    end
  end

  describe :kind do
    it "must return class/type combo" do
      subject.kind.must_equal "TACAN"
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [TACAN] TACAN NAVAID -->
        <Tcn source="LF|GEN|0.0 FACTORY|0|0">
          <TcnUid region="LF">
            <codeId>TTT</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </TcnUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
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

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.name = subject.z = subject.timetable = subject.remarks = nil
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [TACAN] UNNAMED -->
        <Tcn source="LF|GEN|0.0 FACTORY|0|0">
          <TcnUid region="LF">
            <codeId>TTT</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </TcnUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeChannel>29X</codeChannel>
          <codeDatum>WGE</codeDatum>
        </Tcn>
      END
    end
  end
end
