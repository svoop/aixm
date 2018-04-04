require_relative '../../../spec_helper'

describe AIXM::Feature::Airport do
  subject do
    AIXM::Factory.airport
  end

  describe :initialize do
    it "sets defaults" do
      subject = AIXM::Feature::Airport.new(
        code: 'LFNT',
        name: 'Avignon-Pujaut',
        xy: AIXM.xy(lat: %q(43°59'46"N), long: %q(004°45'16"E))
      )
      subject.runways.must_equal []
      subject.helipads.must_equal []
      subject.usage_limitations.must_equal []
    end
  end

  describe :code= do
    it "fails on invalid values" do
      -> { subject.code = 'A' }.must_raise ArgumentError
      -> { subject.code = 'AB' }.must_raise ArgumentError
      -> { subject.code = 'ABCDE' }.must_raise ArgumentError
      -> { subject.code = 'AB12345' }.must_raise ArgumentError
    end

    it "upcases valid values" do
      subject.tap { |s| s.code = 'lfnt' }.code.must_equal 'LFNT'
    end
  end

  describe :name= do
    it "fails on invalid values" do
      -> { subject.name = nil }.must_raise ArgumentError
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'Nîmes-Alès' }.name.must_equal 'NIMES-ALES'
    end
  end

  describe :gps= do
    it "fails on invalid values" do
      -> { subject.gps = :foobar }.must_raise ArgumentError
    end

    it "accepts nil value" do
      subject.tap { |s| s.gps = nil }.gps.must_be :nil?
    end

    it "upcases valid values" do
      subject.tap { |s| s.gps = 'Ebdeurne' }.gps.must_equal 'EBDEURNE'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "fails on values derived from runways and helipads" do
      -> { subject.type = :aerodrome }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.type = :landing_site }.type.must_equal :landing_site
      subject.tap { |s| s.type = :LS }.type.must_equal :landing_site
    end

    it "derives values from runways and helipads" do
      subject.type.must_equal :aerodrome
    end
  end

  describe :xy= do
    macro :xy
  end

  describe :z= do
    macro :z_qnh
  end

  describe :declination= do
    it "fails on invalid values" do
      -> { subject.declination = nil }.must_raise ArgumentError
      -> { subject.declination = :foobar }.must_raise ArgumentError
    end

    it "normalizes valid values" do
      subject.tap { |s| s.declination = 10 }.declination.must_equal 10.0
      subject.tap { |s| s.declination = 20.0 }.declination.must_equal 20.0
    end
  end

  describe :transition_z= do
    it "fails on invalid values" do
      -> { subject.z = 123 }.must_raise ArgumentError
      -> { subject.z = AIXM.z(123, :qfe) }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.z = AIXM.z(123, :qnh) }.z.must_equal AIXM.z(123, :qnh)
    end
  end

  describe :schedule= do
    macro :schedule
  end

  describe :remarks= do
    macro :remarks
  end

  describe :add_runway do
    it "fails on invalid arguments" do
      -> { subject.add_runway nil }.must_raise ArgumentError
    end

    it "adds runway to the array" do
      count = subject.runways.count
      subject.add_runway(AIXM.runway(name: '10'))
      subject.runways.count.must_equal count + 1
    end
  end

# describe :add_helipad do
#   it "fails on invalid arguments" do
#     -> { subject.add_helipad nil }.must_raise ArgumentError
#   end
#
#    it "adds helipad to the array" do
#     count = subject.helipads.count
#     subject.add_helipad(AIXM.helipad(name: '10'))
#     subject.helipads.count.must_equal count + 1
#   end
# end

  describe :add_usage_limitation do
    it "fails on invalid arguments" do
      -> { subject.add_usage_limitation(:foobar) }.must_raise ArgumentError
    end

    context "without block" do
      it "accepts simple limitation" do
        count = subject.usage_limitations.count
        subject.add_usage_limitation(:permitted)
        subject.usage_limitations.count.must_equal count + 1
        subject.usage_limitations.last.limitation.must_equal :permitted
      end
    end

    context "with block" do
      it "accepts complex limitation" do
        count = subject.usage_limitations.count
        subject.add_usage_limitation(:permitted) do |permitted|
          permitted.add_condition { |c| c.aircraft = :glider }
          permitted.add_condition { |c| c.rule = :ifr }
        end
        subject.usage_limitations.count.must_equal count + 1
        subject.usage_limitations.last.conditions.count.must_equal 2
      end
    end
  end

  describe :to_xml do
    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <Ahp source="LF|GEN|0.0 FACTORY|0|0">
          <AhpUid region="LF">
            <codeId>LFNT</codeId>
          </AhpUid>
          <txtName>AVIGNON-PUJAUT</txtName>
          <codeIcao>LFNT</codeIcao>
          <codeGps>LFPUJAUT</codeGps>
          <codeType>AD</codeType>
          <geoLat>43.99611111N</geoLat>
          <geoLong>004.75444444E</geoLong>
          <codeDatum>WGE</codeDatum>
          <valElev>146</valElev>
          <uomDistVer>FT</uomDistVer>
          <valMagVar>1.08</valMagVar>
          <valTransitionAlt>10000</valTransitionAlt>
          <uomTransitionAlt>FT</uomTransitionAlt>
          <txtRmk>Restricted access</txtRmk>
        </Ahp>
        <Rwy>
          <RwyUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>16L/34R</txtDesig>
          </RwyUid>
          <valLen>650</valLen>
          <valWid>80</valWid>
          <uomDimRwy>M</uomDimRwy>
          <codeComposition>GRADE</codeComposition>
          <codeSts>CLSD</codeSts>
          <txtRmk>Markings eroded</txtRmk>
        </Rwy>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
          <valTrueBrg>165</valTrueBrg>
          <valMagBrg>166</valMagBrg>
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <txtRmk>forth remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codeType>DPLM</codeType>
            <codeDayPeriod>A</codeDayPeriod>
          </RddUid>
          <valDist>131</valDist>
          <uomDist>M</uomDist>
          <txtRmk>forth remarks</txtRmk>
        </Rdd>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>34R</txtDesig>
          </RdnUid>
          <geoLat>43.99036389N</geoLat>
          <geoLong>004.75645556E</geoLong>
          <valTrueBrg>345</valTrueBrg>
          <valMagBrg>346</valMagBrg>
          <txtRmk>back remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>34R</txtDesig>
            </RdnUid>
            <codeType>DPLM</codeType>
            <codeDayPeriod>A</codeDayPeriod>
          </RddUid>
          <valDist>209</valDist>
          <uomDist>M</uomDist>
          <txtRmk>back remarks</txtRmk>
        </Rdd>
        <Ahu>
          <AhuUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
          </AhuUid>
          <UsageLimitation>
            <codeUsageLimitation>PERMIT</codeUsageLimitation>
          </UsageLimitation>
          <UsageLimitation>
            <codeUsageLimitation>RESERV</codeUsageLimitation>
            <UsageCondition>
              <AircraftClass>
                <codeType>E</codeType>
              </AircraftClass>
            </UsageCondition>
            <UsageCondition>
              <FlightClass>
                <codeOrigin>INTL</codeOrigin>
              </FlightClass>
            </UsageCondition>
            <Timetable>
              <codeWorkHr>H24</codeWorkHr>
            </Timetable>
            <txtRmk>reservation remarks</txtRmk>
          </UsageLimitation>
        </Ahu>
      END
    end
  end
end

describe AIXM::Feature::Airport::UsageLimitation do
  subject do
    AIXM::Factory.airport.usage_limitations.first
  end

  describe :initialize do
    it "sets defaults" do
      subject.conditions.must_equal []
    end
  end

  describe :limitation= do
    it "fails on invalid values" do
      -> { subject.limitation = :foobar }.must_raise ArgumentError
      -> { subject.limitation = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.limitation = :permitted }.limitation.must_equal :permitted
      subject.tap { |s| s.limitation = :RESERV }.limitation.must_equal :reservation_required
    end
  end

  describe :schedule= do
    macro :schedule
  end

  describe :remarks= do
    macro :remarks
  end
end

describe AIXM::Feature::Airport::UsageLimitation::Condition do
  subject do
    AIXM::Factory.airport.usage_limitations.last.conditions.first
  end

  describe :aircraft= do
    it "fails on invalid values" do
      -> { subject.aircraft = :foobar }.must_raise ArgumentError
      -> { subject.aircraft = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.aircraft = :glider }.aircraft.must_equal :glider
      subject.tap { |s| s.aircraft = :H }.aircraft.must_equal :helicopter
    end
  end

  describe :rule= do
    it "fails on invalid values" do
      -> { subject.rule = :foobar }.must_raise ArgumentError
      -> { subject.rule = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.rule = :ifr }.rule.must_equal :ifr
      subject.tap { |s| s.rule = :IV }.rule.must_equal :ifr_and_vfr
    end
  end

  describe :realm= do
    it "fails on invalid values" do
      -> { subject.realm = :foobar }.must_raise ArgumentError
      -> { subject.realm = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.realm = :civil }.realm.must_equal :civil
      subject.tap { |s| s.realm = :MIL }.realm.must_equal :military
    end
  end

  describe :origin= do
    it "fails on invalid values" do
      -> { subject.origin = :foobar }.must_raise ArgumentError
      -> { subject.origin = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.origin = :international }.origin.must_equal :international
      subject.tap { |s| s.origin = :NTL }.origin.must_equal :national
    end
  end

  describe :purpose= do
    it "fails on invalid values" do
      -> { subject.purpose = :foobar }.must_raise ArgumentError
      -> { subject.purpose = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.purpose = :private }.purpose.must_equal :private
      subject.tap { |s| s.purpose = :TRG }.purpose.must_equal :school_or_training
    end
  end
end
