require_relative '../../../spec_helper'

describe AIXM::Feature::Airport do
  subject do
    AIXM::Factory.airport
  end

  describe :initialize do
    it "sets defaults" do
      subject = AIXM::Feature::Airport.new(
        organisation: AIXM::Factory.organisation,
        code: 'LFNT',
        name: 'Avignon-Pujaut',
        xy: AIXM.xy(lat: %q(43°59'46"N), long: %q(004°45'16"E))
      )
      subject.runways.must_equal []
      subject.helipads.must_equal []
      subject.usage_limitations.must_equal []
    end
  end

  describe :organisation= do
    it "fails on invalid values" do
      [nil, :foobar].wont_be_written_to subject, :organisation
    end
  end

  describe :code= do
    it "fails on invalid values" do
      [nil, 'A', 'AB', 'ABCDE', 'AB12345'].wont_be_written_to subject, :code
    end

    it "upcases valid values" do
      subject.tap { |s| s.code = 'lfnt' }.code.must_equal 'LFNT'
    end
  end

  describe :name= do
    it "fails on invalid values" do
      [nil, 123].wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'Nîmes-Alès' }.name.must_equal 'NIMES-ALES'
    end
  end

  describe :gps= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :gps
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :gps
    end

    it "upcases valid values" do
      subject.tap { |s| s.gps = 'Ebdeurne' }.gps.must_equal 'EBDEURNE'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      [nil, :foobar].wont_be_written_to subject, :type
    end

    it "fails on values derived from runways and helipads" do
      [:aerodrome, :heliport, :aerodrome_and_heliport].wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      subject.tap { |s| s.type = :landing_site }.type.must_equal :landing_site
      subject.tap { |s| s.type = :LS }.type.must_equal :landing_site
    end

    it "derives values from runways and helipads" do
      subject.type.must_equal :aerodrome_and_heliport
    end
  end

  describe :xy= do
    macro :xy

    it "fails on nil values" do
      [nil].wont_be_written_to subject, :xy
    end
  end

  describe :z= do
    macro :z_qnh

    it "accepts nil value" do
      [nil].must_be_written_to subject, :z
    end
  end

  describe :declination= do
    it "fails on invalid values" do
      [:foobar, false].wont_be_written_to subject, :declination
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :declination
    end

    it "converts valid values to Float" do
      subject.tap { |s| s.declination = 10 }.declination.must_equal 10.0
      subject.tap { |s| s.declination = 20.0 }.declination.must_equal 20.0
    end
  end

  describe :transition_z= do
    it "fails on invalid values" do
      [123, AIXM.z(123, :qfe)].wont_be_written_to subject, :transition_z
    end

    it "accepts valid values" do
      [nil, AIXM.z(123, :qnh)].must_be_written_to subject, :transition_z
    end
  end

  describe :timetable= do
    macro :timetable
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

  describe :add_helipad do
    it "fails on invalid arguments" do
      -> { subject.add_helipad nil }.must_raise ArgumentError
    end

    it "adds helipad to the array" do
      count = subject.helipads.count
      subject.add_helipad(AIXM.helipad(name: 'H2'))
      subject.helipads.count.must_equal count + 1
    end
  end

  describe :add_usage_limitation do
    it "fails on invalid arguments" do
      -> { subject.add_usage_limitation(:foobar) }.must_raise ArgumentError
    end

    context "without block" do
      it "accepts simple limitation" do
        count = subject.usage_limitations.count
        subject.add_usage_limitation(:permitted)
        subject.usage_limitations.count.must_equal count + 1
        subject.usage_limitations.last.type.must_equal :permitted
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
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <!-- Airport: LFNT AVIGNON-PUJAUT -->
        <Ahp source="LF|GEN|0.0 FACTORY|0|0">
          <AhpUid region="LF">
            <codeId>LFNT</codeId>
          </AhpUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <txtName>AVIGNON-PUJAUT</txtName>
          <codeIcao>LFNT</codeIcao>
          <codeGps>LFPUJAUT</codeGps>
          <codeType>AH</codeType>
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
        <Tla>
          <TlaUid>
            <AhpUid region=\"LF\">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <geoLat>43.99915000N</geoLat>
          <geoLong>004.75154444E</geoLong>
          <codeDatum>WGE</codeDatum>
          <valElev>141</valElev>
          <uomDistVer>FT</uomDistVer>
          <valLen>20</valLen>
          <valWid>20</valWid>
          <uomDim>M</uomDim>
          <codeComposition>GRASS</codeComposition>
          <codeSts>OTHER</codeSts>
          <txtRmk>Authorizaton by AD operator required</txtRmk>
        </Tla>
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

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.z = subject.declination = subject.transition_z = subject.remarks = nil
      subject.instance_variable_set(:'@runways', [])
      subject.instance_variable_set(:'@helipads', [])
      subject.instance_variable_set(:'@usage_limitations', [])
      subject.to_xml.must_equal <<~END
        <!-- Airport: LFNT AVIGNON-PUJAUT -->
        <Ahp source="LF|GEN|0.0 FACTORY|0|0">
          <AhpUid region="LF">
            <codeId>LFNT</codeId>
          </AhpUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <txtName>AVIGNON-PUJAUT</txtName>
          <codeIcao>LFNT</codeIcao>
          <codeGps>LFPUJAUT</codeGps>
          <geoLat>43.99611111N</geoLat>
          <geoLong>004.75444444E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Ahp>
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

  describe :type= do
    it "fails on invalid values" do
      [nil, :foobar].wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      subject.tap { |s| s.type = :permitted }.type.must_equal :permitted
      subject.tap { |s| s.type = :RESERV }.type.must_equal :reservation_required
    end
  end

  describe :timetable= do
    macro :timetable
  end

  describe :remarks= do
    macro :remarks
  end

  describe :xml= do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject = AIXM::Factory.airport.usage_limitations.last
      subject.to_xml.must_equal <<~END
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
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <UsageLimitation>
          <codeUsageLimitation>PERMIT</codeUsageLimitation>
        </UsageLimitation>
      END
    end
  end
end

describe AIXM::Feature::Airport::UsageLimitation::Condition do
  subject do
    AIXM::Factory.airport.usage_limitations.last.conditions.first
  end

  describe :aircraft= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :aircraft
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :aircraft
    end

    it "looks up valid values" do
      subject.tap { |s| s.aircraft = :glider }.aircraft.must_equal :glider
      subject.tap { |s| s.aircraft = :H }.aircraft.must_equal :helicopter
    end
  end

  describe :rule= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :rule
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :rule
    end

    it "looks up valid values" do
      subject.tap { |s| s.rule = :ifr }.rule.must_equal :ifr
      subject.tap { |s| s.rule = :IV }.rule.must_equal :ifr_and_vfr
    end
  end

  describe :realm= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :realm
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :realm
    end

    it "looks up valid values" do
      subject.tap { |s| s.realm = :civilian }.realm.must_equal :civilian
      subject.tap { |s| s.realm = :MIL }.realm.must_equal :military
    end
  end

  describe :origin= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :origin
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :origin
    end

    it "looks up valid values" do
      subject.tap { |s| s.origin = :international }.origin.must_equal :international
      subject.tap { |s| s.origin = :NTL }.origin.must_equal :national
    end
  end

  describe :purpose= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :purpose
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :purpose
    end

    it "looks up valid values" do
      subject.tap { |s| s.purpose = :private }.purpose.must_equal :private
      subject.tap { |s| s.purpose = :TRG }.purpose.must_equal :school_or_training
    end
  end

  describe :xml= do
    it "builds correct complete OFMX" do
      subject.rule = :vfr
      subject.realm = :military
      subject.origin = :international
      subject.purpose = :school_or_training
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <UsageCondition>
          <AircraftClass>
            <codeType>E</codeType>
          </AircraftClass>
          <FlightClass>
            <codeRule>V</codeRule>
            <codeMil>MIL</codeMil>
            <codeOrigin>INTL</codeOrigin>
            <codePurpose>TRG</codePurpose>
          </FlightClass>
        </UsageCondition>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <UsageCondition>
          <AircraftClass>
            <codeType>E</codeType>
          </AircraftClass>
        </UsageCondition>
      END
    end
  end
end
