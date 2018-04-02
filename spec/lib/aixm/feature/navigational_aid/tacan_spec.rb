require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::TACAN do
  subject do
    AIXM::Factory.tacan
  end

  describe :channel= do
    it "fails on invalid values" do
      -> { subject.channel = 123 }.must_raise ArgumentError
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
    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- NavigationalAid: [TACAN] TACAN NAVAID -->
        <Tcn>
          <TcnUid region="LF">
            <codeId>TTT</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
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
