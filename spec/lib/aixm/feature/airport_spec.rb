require_relative '../../../spec_helper'

describe AIXM::Feature::Airport do
  subject do
    AIXM::Factory.airport
  end

  describe :id= do
    it "fails on invalid values" do
      _([nil, 'A', 'ABCDE', 'AB 1234']).wont_be_written_to subject, :id
    end

    it "combines 2 character region with an 8 characters digest from name" do
      _(subject.tap { _1.id = 'lf' }.id).must_equal 'LFD18754F5'
      _(subject.tap { _1.name = 'OTHER'; _1.id = 'lf' }.id).must_equal 'LFD646E0F9'
    end

    it "upcases valid values" do
      _(subject.tap { _1.id = 'lfnt' }.id).must_equal 'LFNT'
    end
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, 123]).wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { _1.name = 'Nîmes-Alès' }.name).must_equal 'NIMES-ALES'
    end
  end

  describe :gps= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :gps
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :gps
    end

    it "upcases valid values" do
      _(subject.tap { _1.gps = 'Ebdeurne' }.gps).must_equal 'EBDEURNE'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _([nil, :foobar]).wont_be_written_to subject, :type
    end

    it "fails on values derived from runways and helipads" do
      _([:aerodrome, :heliport, :aerodrome_and_heliport]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { _1.type = :landing_site }.type).must_equal :landing_site
      _(subject.tap { _1.type = :LS }.type).must_equal :landing_site
    end

    it "derives values from runways and helipads" do
      _(subject.type).must_equal :aerodrome_and_heliport
    end
  end

  describe :xy= do
    macro :xy

    it "fails on nil values" do
      _([nil]).wont_be_written_to subject, :xy
    end
  end

  describe :z= do
    macro :z_qnh

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :z
    end
  end

  describe :declination= do
    it "fails on invalid values" do
      _([:foobar, false]).wont_be_written_to subject, :declination
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :declination
    end

    it "converts valid values to Float" do
      _(subject.tap { _1.declination = 10 }.declination).must_equal 10.0
      _(subject.tap { _1.declination = 20.0 }.declination).must_equal 20.0
    end
  end

  describe :transition_z= do
    it "fails on invalid values" do
      _([123, AIXM.z(123, :qfe)]).wont_be_written_to subject, :transition_z
    end

    it "accepts valid values" do
      _([nil, AIXM.z(123, :qnh)]).must_be_written_to subject, :transition_z
    end
  end

  describe :timetable= do
    macro :timetable
  end

  describe :operator= do
    it "fails on invalid values" do
      _([123]).wont_be_written_to subject, :operator
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :operator
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { _1.operator = 'Municipality of Nîmes-Alès' }.operator).must_equal 'MUNICIPALITY OF NIMES-ALES'
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :add_usage_limitation do
    it "fails on invalid arguments" do
      _{ subject.add_usage_limitation(type: :foobar) }.must_raise ArgumentError
    end

    context "without block" do
      it "accepts simple limitation" do
        count = subject.usage_limitations.count
        subject.add_usage_limitation(type: :permitted)
        _(subject.usage_limitations.count).must_equal count + 1
        _(subject.usage_limitations.last.type).must_equal :permitted
      end
    end

    context "with block" do
      it "accepts complex limitation" do
        count = subject.usage_limitations.count
        subject.add_usage_limitation(type: :permitted) do |permitted|
          permitted.add_condition { _1.aircraft = :glider }
          permitted.add_condition { _1.rule = :ifr }
        end
        _(subject.usage_limitations.count).must_equal count + 1
        _(subject.usage_limitations.last.conditions.count).must_equal 2
      end
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.add_address(AIXM.address(source: "LF|GEN|0.0 FACTORY|0|0", type: :url, address: 'https://lfnt.tower.zone'))
      subject.add_address(AIXM.address(source: "LF|GEN|0.0 FACTORY|0|0", type: :url, address: 'https://planeur-avignon-pujaut.fr'))
      _(subject.to_xml).must_equal <<~END
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
          <txtNameAdmin>MUNICIPALITY OF PUJAUT</txtNameAdmin>
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
          <codeComposition>ASPH</codeComposition>
          <codePreparation>PAVED</codePreparation>
          <codeCondSfc>GOOD</codeCondSfc>
          <valPcnClass>59</valPcnClass>
          <codePcnPavementType>F</codePcnPavementType>
          <codePcnPavementSubgrade>A</codePcnPavementSubgrade>
          <codePcnMaxTirePressure>W</codePcnMaxTirePressure>
          <codePcnEvalMethod>T</codePcnEvalMethod>
          <txtPcnNote>Paved shoulder on 2.5m on each side of the RWY.</txtPcnNote>
          <valSiwlWeight>1500</valSiwlWeight>
          <uomSiwlWeight>KG</uomSiwlWeight>
          <valSiwlTirePressure>0.5</valSiwlTirePressure>
          <uomSiwlTirePressure>MPA</uomSiwlTirePressure>
          <valAuwWeight>30</valAuwWeight>
          <uomAuwWeight>T</uomAuwWeight>
          <codeSts>CLSD</codeSts>
          <txtMarking>Standard marking</txtMarking>
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
          <valMagBrg>164</valMagBrg>
          <valElevTdz>145</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeVfrPattern>E</codeVfrPattern>
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
        <Rls>
          <RlsUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codePsn>AIM</codePsn>
          </RlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Rls>
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
          <valMagBrg>344</valMagBrg>
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeVfrPattern>L</codeVfrPattern>
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
        <Rls>
          <RlsUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>34R</txtDesig>
            </RdnUid>
            <codePsn>AIM</codePsn>
          </RlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Rls>
        <Fto>
          <FtoUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
          <valLen>35</valLen>
          <valWid>35</valWid>
          <uomDim>M</uomDim>
          <codeComposition>CONC</codeComposition>
          <codePreparation>PAVED</codePreparation>
          <codeCondSfc>FAIR</codeCondSfc>
          <valPcnClass>30</valPcnClass>
          <codePcnPavementType>F</codePcnPavementType>
          <codePcnPavementSubgrade>A</codePcnPavementSubgrade>
          <codePcnMaxTirePressure>W</codePcnMaxTirePressure>
          <codePcnEvalMethod>U</codePcnEvalMethod>
          <txtPcnNote>Cracks near the center</txtPcnNote>
          <valSiwlWeight>1500</valSiwlWeight>
          <uomSiwlWeight>KG</uomSiwlWeight>
          <valSiwlTirePressure>0.5</valSiwlTirePressure>
          <uomSiwlTirePressure>MPA</uomSiwlTirePressure>
          <valAuwWeight>8</valAuwWeight>
          <uomAuwWeight>T</uomAuwWeight>
          <txtProfile>Northwest from RWY 12/30</txtProfile>
          <txtMarking>Dashed white lines</txtMarking>
          <codeSts>OTHER</codeSts>
          <txtRmk>Authorizaton by AD operator required</txtRmk>
        </Fto>
        <Fdn>
          <FdnUid>
            <FtoUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </FtoUid>
            <txtDesig>35</txtDesig>
          </FdnUid>
          <valTrueBrg>355</valTrueBrg>
          <valMagBrg>354</valMagBrg>
          <txtRmk>Avoid flight over residental area</txtRmk>
        </Fdn>
        <Fls>
          <FlsUid>
            <FdnUid>
              <FtoUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>H1</txtDesig>
              </FtoUid>
              <txtDesig>35</txtDesig>
            </FdnUid>
            <codePsn>AIM</codePsn>
          </FlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Fls>
        <Tla>
          <TlaUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <FtoUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
          <geoLat>43.99915000N</geoLat>
          <geoLong>004.75154444E</geoLong>
          <codeDatum>WGE</codeDatum>
          <valElev>141</valElev>
          <uomDistVer>FT</uomDistVer>
          <valLen>20</valLen>
          <valWid>20</valWid>
          <uomDim>M</uomDim>
          <codeComposition>CONC</codeComposition>
          <codePreparation>PAVED</codePreparation>
          <codeCondSfc>FAIR</codeCondSfc>
          <valPcnClass>30</valPcnClass>
          <codePcnPavementType>F</codePcnPavementType>
          <codePcnPavementSubgrade>A</codePcnPavementSubgrade>
          <codePcnMaxTirePressure>W</codePcnMaxTirePressure>
          <codePcnEvalMethod>U</codePcnEvalMethod>
          <txtPcnNote>Cracks near the center</txtPcnNote>
          <valSiwlWeight>1500</valSiwlWeight>
          <uomSiwlWeight>KG</uomSiwlWeight>
          <valSiwlTirePressure>0.5</valSiwlTirePressure>
          <uomSiwlTirePressure>MPA</uomSiwlTirePressure>
          <valAuwWeight>8</valAuwWeight>
          <uomAuwWeight>T</uomAuwWeight>
          <codeClassHel>1</codeClassHel>
          <txtMarking>Continuous white lines</txtMarking>
          <codeSts>OTHER</codeSts>
          <txtRmk>Authorizaton by AD operator required</txtRmk>
        </Tla>
        <Tls>
          <TlsUid>
            <TlaUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </TlaUid>
            <codePsn>AIM</codePsn>
          </TlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Tls>
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
        <!-- Address: RADIO for LFNT -->
        <Aha source="LF|GEN|0.0 FACTORY|0|0">
          <AhaUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeType>RADIO</codeType>
            <noSeq>1</noSeq>
          </AhaUid>
          <txtAddress>123.35 mhz</txtAddress>
          <txtRmk>A/A (callsign PUJAUT)</txtRmk>
        </Aha>
        <!-- Address: URL for LFNT -->
        <Aha source="LF|GEN|0.0 FACTORY|0|0">
          <AhaUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeType>URL</codeType>
            <noSeq>1</noSeq>
          </AhaUid>
          <txtAddress>https://lfnt.tower.zone</txtAddress>
        </Aha>
        <!-- Address: URL for LFNT -->
        <Aha source="LF|GEN|0.0 FACTORY|0|0">
          <AhaUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeType>URL</codeType>
            <noSeq>2</noSeq>
          </AhaUid>
          <txtAddress>https://planeur-avignon-pujaut.fr</txtAddress>
        </Aha>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(z declination transition_z operator remarks).each { subject.send(:"#{_1}=", nil) }
      subject.instance_eval { @addresses.clear }
      subject.instance_eval { @runways.clear }
      subject.instance_eval { @fatos.clear }
      subject.instance_eval { @helipads.clear }
      subject.instance_eval { @usage_limitations.clear }
      _(subject.to_xml).must_equal <<~END
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

  describe :type= do
    it "fails on invalid values" do
      _([nil, :foobar]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { _1.type = :permitted }.type).must_equal :permitted
      _(subject.tap { _1.type = :RESERV }.type).must_equal :reservation_required
    end
  end

  describe :timetable= do
    macro :timetable
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject = AIXM::Factory.airport.usage_limitations.last
      _(subject.to_xml).must_equal <<~END
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
      _(subject.to_xml).must_equal <<~END
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
      _([:foobar, 123]).wont_be_written_to subject, :aircraft
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :aircraft
    end

    it "looks up valid values" do
      _(subject.tap { _1.aircraft = :glider }.aircraft).must_equal :glider
      _(subject.tap { _1.aircraft = :H }.aircraft).must_equal :helicopter
    end
  end

  describe :rule= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :rule
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :rule
    end

    it "looks up valid values" do
      _(subject.tap { _1.rule = :ifr }.rule).must_equal :ifr
      _(subject.tap { _1.rule = :IV }.rule).must_equal :ifr_and_vfr
    end
  end

  describe :realm= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :realm
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :realm
    end

    it "looks up valid values" do
      _(subject.tap { _1.realm = :civilian }.realm).must_equal :civilian
      _(subject.tap { _1.realm = :MIL }.realm).must_equal :military
    end
  end

  describe :origin= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :origin
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :origin
    end

    it "looks up valid values" do
      _(subject.tap { _1.origin = :international }.origin).must_equal :international
      _(subject.tap { _1.origin = :NTL }.origin).must_equal :national
    end
  end

  describe :purpose= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :purpose
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :purpose
    end

    it "looks up valid values" do
      _(subject.tap { _1.purpose = :private }.purpose).must_equal :private
      _(subject.tap { _1.purpose = :TRG }.purpose).must_equal :school_or_training
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      subject.rule = :vfr
      subject.realm = :military
      subject.origin = :international
      subject.purpose = :school_or_training
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
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
      _(subject.to_xml).must_equal <<~END
        <UsageCondition>
          <AircraftClass>
            <codeType>E</codeType>
          </AircraftClass>
        </UsageCondition>
      END
    end
  end
end
