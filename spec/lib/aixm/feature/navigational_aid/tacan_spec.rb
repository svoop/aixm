require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::TACAN do
  CHANNELS = {
    '1X' => AIXM.f(134.4, :mhz),
    '12Y' => AIXM.f(135.55, :mhz),
    '16Y' => AIXM.f(135.95, :mhz),
    '17X' => AIXM.f(108, :mhz),
    '30X' => AIXM.f(109.3, :mhz),
    '59Y' => AIXM.f(112.25, :mhz),
    '60X' => AIXM.f(133.3, :mhz),
    '64Y' => AIXM.f(133.75, :mhz),
    '69Y' => AIXM.f(134.25, :mhz),
    '70X' => AIXM.f(112.30, :mhz),
    '100X' => AIXM.f(115.3, :mhz),
    '126Y' => AIXM.f(117.95, :mhz)
  }

  subject do
    AIXM::Factory.tacan
  end

  describe :channel= do
    it "fails on invalid values" do
      _([nil, :foobar, 123, '0X', '127Y', '12Z']).wont_be_written_to subject, :channel
    end
  end

  describe :ghost_f= do
    it "must set the corresponding channel" do
      CHANNELS.each do |channel, f|
        _(subject.tap { _1.ghost_f = f }.channel).must_equal channel
        _(subject.tap { _1.ghost_f = f }.ghost_f).must_equal f
      end
    end

    it "can be used to initialize a Tacan" do
      same_dme = AIXM.tacan(
        organisation: AIXM::Factory.organisation,
        id: 'MMM',
        xy: AIXM.xy(lat: %q(47°51'33"N), long: %q(007°33'36"E)),
        ghost_f: AIXM.f(114.8, :mhz)
      )
      _(same_dme.channel).must_equal '95X'
    end
  end

  describe :ghost_f do
    it "must be derived from the channel" do
      CHANNELS.each do |channel, f|
        _(subject.tap { _1.channel = channel }.ghost_f).must_equal f
      end
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
          <TcnUid region="LF">
            <codeId>TTT</codeId>
            <geoLat>47.85916667N</geoLat>
            <geoLong>007.56000000E</geoLong>
          </TcnUid>
          <OrgUid region="LF">
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
