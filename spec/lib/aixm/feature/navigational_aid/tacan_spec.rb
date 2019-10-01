require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::TACAN do
  subject do
    AIXM::Factory.tacan
  end

  describe :channel= do
    it "fails on invalid values" do
      _([nil, :foobar, 123, '0X', '127Y', '12Z']).wont_be_written_to subject, :channel
    end
  end

  describe :ghost_f do
    it "must be derived from the channel" do
      _(subject.tap { |s| s.channel = '1X' }.ghost_f.freq).must_equal 134.4
      _(subject.tap { |s| s.channel = '12Y' }.ghost_f.freq).must_equal 135.55
      _(subject.tap { |s| s.channel = '16Y' }.ghost_f.freq).must_equal 135.95
      _(subject.tap { |s| s.channel = '17X' }.ghost_f.freq).must_equal 108
      _(subject.tap { |s| s.channel = '30X' }.ghost_f.freq).must_equal 109.3
      _(subject.tap { |s| s.channel = '59Y' }.ghost_f.freq).must_equal 112.25
      _(subject.tap { |s| s.channel = '60X' }.ghost_f.freq).must_equal 133.3
      _(subject.tap { |s| s.channel = '64Y' }.ghost_f.freq).must_equal 133.75
      _(subject.tap { |s| s.channel = '69Y' }.ghost_f.freq).must_equal 134.25
      _(subject.tap { |s| s.channel = '70X' }.ghost_f.freq).must_equal 112.30
      _(subject.tap { |s| s.channel = '100X' }.ghost_f.freq).must_equal 115.3
      _(subject.tap { |s| s.channel = '126Y' }.ghost_f.freq).must_equal 117.95
    end
  end

  describe :kind do
    it "must return class/type combo" do
      _(subject.kind).must_equal "TACAN"
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- NavigationalAid: [TACAN] TTT / TACAN NAVAID -->
        <Tcn source="LF|GEN|0.0 FACTORY|0|0">
          <TcnUid>
            <codeId>TTT</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </TcnUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <txtName>TACAN NAVAID</txtName>
          <codeChannel>29X</codeChannel>
          <valGhostFreq>109.2</valGhostFreq>
          <uomGhostFreq>MHZ</uomGhostFreq>
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
      _(subject.to_xml).must_equal <<~END
        <!-- NavigationalAid: [TACAN] TTT -->
        <Tcn source="LF|GEN|0.0 FACTORY|0|0">
          <TcnUid>
            <codeId>TTT</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </TcnUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeChannel>29X</codeChannel>
          <valGhostFreq>109.2</valGhostFreq>
          <uomGhostFreq>MHZ</uomGhostFreq>
          <codeDatum>WGE</codeDatum>
        </Tcn>
      END
    end
  end
end
