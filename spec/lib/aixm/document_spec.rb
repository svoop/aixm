require_relative '../../spec_helper'

describe AIXM::Document do
  subject do
    AIXM.document
  end

  describe :namespace= do
    it "fails on invalid values" do
      _(['foobar', :foobar]).wont_be_written_to subject, :namespace
    end

    it "sets random UUID for nil value" do
      _(subject.tap { _1.namespace = nil }.namespace).must_match AIXM::Document::NAMESPACE_RE
    end

    it "accepts UUID value" do
      _([SecureRandom.uuid]).must_be_written_to subject, :namespace
    end
  end

  describe :created_at= do
    it "fails on invalid values" do
      _(['foobar', '2018-01-77']).wont_be_written_to subject, :created_at
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      _(subject.tap { _1.created_at = string }.created_at).must_equal Time.parse(string)
    end

    it "falls back to effective_at first" do
      subject.effective_at = Time.now
      subject.created_at = nil
      _(subject.created_at).must_equal subject.effective_at
    end

    it "falls back to now second" do
      subject.created_at = nil
      _(subject.created_at).must_be_close_to Time.now
    end
  end

  describe :effective_at= do
    it "fails on invalid values" do
      _(['foobar', '2018-01-77']).wont_be_written_to subject, :effective_at
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      _(subject.tap { _1.effective_at = string }.effective_at).must_equal Time.parse(string)
    end

    it "falls back to created_at first" do
      subject.effective_at = Time.now
      subject.effective_at = nil
      _(subject.effective_at).must_equal subject.created_at
    end

    it "falls back to now second" do
      subject.effective_at = nil
      _(subject.effective_at).must_be_close_to Time.now
    end
  end

  describe :group_obstacles! do
    subject do
      AIXM.document.tap do |document|
        {
          1 => AIXM.xy(lat: 32.665623, long: -111.488584),   # 4 north ends:
          2 => AIXM.xy(lat: 32.665613, long: -111.487701),   # 84m distance between each
          3 => AIXM.xy(lat: 32.665603, long: -111.486796),   # 505m distance to south ends
          4 => AIXM.xy(lat: 32.665611, long: -111.485902),
          5 => AIXM.xy(lat: 32.661062, long: -111.488624),   # 4 south ends:
          6 => AIXM.xy(lat: 32.661061, long: -111.487731),   # 84m distance between each
          7 => AIXM.xy(lat: 32.661042, long: -111.486814),   # 505m distance to north ends
          8 => AIXM.xy(lat: 32.661054, long: -111.485931),
          9 => AIXM.xy(lat: 0, long: 0)                      # far away from the others
        }.to_a.shuffle.each do |index, xy|
          document.add_feature AIXM.obstacle(
            source: index.to_s,
            name: index.to_s,
            type: :other,
            xy: xy,
            radius: AIXM.d(10, :m),
            z: AIXM.z(1680 , :qnh)
          )
        end
      end
    end

    it "adds 1 group of obstacles with default max distance" do
      _(subject.group_obstacles!).must_equal 1
      obstacle_group = subject.features.find_by(:obstacle_group).first
      _(obstacle_group.obstacles.count).must_equal 8
      _(subject.features.find_by(:obstacle).count).must_equal 1
    end

    it "adds 2 groups of obstacles with max distance 400m" do
      _(subject.group_obstacles!(max_distance: AIXM.d(400, :m))).must_equal 2
      obstacle_groups = subject.features.select { _1.is_a? AIXM::Feature::ObstacleGroup }
      obstacle_groups.each do |obstacle_group|
        names = obstacle_group.obstacles.map(&:name).sort
        _(names).must_equal names.include?('1') ? %w(1 2 3 4) : %w(5 6 7 8)
      end
      _(subject.features.find_by(:obstacle).count).must_equal 1
    end

    it "leaves ungrouped obstacles untouched" do
      subject.group_obstacles!
      _(subject.features.find_by(:obstacle).count).must_equal 1
    end

    it "copies source of first obstacle to obstacle group" do
      subject.group_obstacles!
      obstacle_group = subject.features.find_by(:obstacle_group).first
      _(obstacle_group.source).must_equal obstacle_group.obstacles.first.source
    end

    it "returns number of groups" do
      _(subject.group_obstacles!).must_equal 1
    end
  end

  context "AIXM" do
    subject do
      AIXM::Factory.document
    end

    it "won't have errors" do
      _(subject.errors).must_equal []
    end

    it "builds correct AIXM" do
      _(subject.to_xml).must_equal <<~"END"
        <?xml version="1.0" encoding="UTF-8"?>
        <AIXM-Snapshot xmlns:xsi="http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd" version="4.5" origin="rubygem aixm-#{AIXM::VERSION}" created="2018-01-01T12:00:00+01:00" effective="2018-01-01T12:00:00+01:00">
          <!-- Organisation: FRANCE -->
          <Org>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <codeId>LF</codeId>
            <codeType>S</codeType>
            <txtRmk>Oversea departments not included</txtRmk>
          </Org>
          <!-- Unit: PUJAUT TWR -->
          <Uni>
            <UniUid>
              <txtName>PUJAUT</txtName>
            </UniUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeType>TWR</codeType>
            <codeClass>ICAO</codeClass>
            <txtRmk>FR only</txtRmk>
          </Uni>
          <!-- Service: APP by PUJAUT TWR -->
          <Ser>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT</txtName>
              </UniUid>
              <codeType>APP</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <Stt>
              <codeWorkHr>H24</codeWorkHr>
            </Stt>
            <txtRmk>service remarks</txtRmk>
          </Ser>
          <Fqy>
            <FqyUid>
              <SerUid>
                <UniUid>
                  <txtName>PUJAUT</txtName>
                </UniUid>
                <codeType>APP</codeType>
                <noSeq>1</noSeq>
              </SerUid>
              <valFreqTrans>123.35</valFreqTrans>
            </FqyUid>
            <valFreqRec>124.1</valFreqRec>
            <uomFreq>MHZ</uomFreq>
            <Ftt>
              <codeWorkHr>H24</codeWorkHr>
            </Ftt>
            <txtRmk>frequency remarks</txtRmk>
            <Cdl>
              <txtCallSign>PUJAUT CONTROL</txtCallSign>
              <codeLang>EN</codeLang>
            </Cdl>
            <Cdl>
              <txtCallSign>PUJAUT CONTROLE</txtCallSign>
              <codeLang>FR</codeLang>
            </Cdl>
          </Fqy>
          <!-- Airport: LFNT AVIGNON-PUJAUT -->
          <Ahp>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>AVIGNON-PUJAUT</txtName>
            <codeIcao>LFNT</codeIcao>
            <codeType>AH</codeType>
            <geoLat>435946.00N</geoLat>
            <geoLong>0044516.00E</geoLong>
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
              <AhpUid>
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
            <txtRmk>Markings eroded</txtRmk>
          </Rwy>
          <Rdn>
            <RdnUid>
              <RwyUid>
                <AhpUid>
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <geoLat>440007.63N</geoLat>
            <geoLong>0044507.81E</geoLong>
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
                  <AhpUid>
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
                  <AhpUid>
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
                <AhpUid>
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>34R</txtDesig>
            </RdnUid>
            <geoLat>435925.31N</geoLat>
            <geoLong>0044523.24E</geoLong>
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
                  <AhpUid>
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
                  <AhpUid>
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
              <AhpUid>
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
                <AhpUid>
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
                  <AhpUid>
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
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </TlaUid>
            <FtoUid>
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </FtoUid>
            <geoLat>435956.94N</geoLat>
            <geoLong>0044505.56E</geoLong>
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
                <AhpUid>
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
              <AhpUid>
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
          <Aha>
            <AhaUid>
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <codeType>RADIO</codeType>
              <noSeq>1</noSeq>
            </AhaUid>
            <txtAddress>123.35 mhz</txtAddress>
            <txtRmk>A/A (callsign PUJAUT)</txtRmk>
          </Aha>
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase>
            <AseUid>
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid>
                <codeType>D</codeType>
                <codeId>PA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>475415.00N</geoLatArc>
              <geoLongArc>0073348.00E</geoLongArc>
            </Avx>
            <Avx>
              <GbrUid>
                <txtName>FRANCE_GERMANY</txtName>
              </GbrUid>
              <codeType>FNT</codeType>
              <geoLat>475637.00N</geoLat>
              <geoLong>0073545.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <!-- Airspace: [D] CIRCLE AIRSPACE -->
          <Ase>
            <AseUid>
              <codeType>D</codeType>
              <codeId>CA</codeId>
            </AseUid>
            <txtLocalType>CIRCLE</txtLocalType>
            <txtName>CIRCLE AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid>
                <codeType>D</codeType>
                <codeId>CA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>474023.76N</geoLat>
              <geoLong>0045300.00E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>473500.00N</geoLatArc>
              <geoLongArc>0045300.00E</geoLongArc>
            </Avx>
          </Abd>
          <!-- NavigationalAid: [DesignatedPoint:VFR-RP] DDD / DESIGNATED POINT NAVAID -->
          <Dpn>
            <DpnUid>
              <codeId>DDD</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </DpnUid>
            <AhpUidAssoc>
              <codeId>LFNT</codeId>
            </AhpUidAssoc>
            <codeDatum>WGE</codeDatum>
            <codeType>OTHER</codeType>
            <txtName>DESIGNATED POINT NAVAID</txtName>
            <txtRmk>designated point navaid</txtRmk>
          </Dpn>
          <!-- NavigationalAid: [DME] MMM / DME NAVAID -->
          <Dme>
            <DmeUid>
              <codeId>MMM</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </DmeUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <valGhostFreq>114.8</valGhostFreq>
            <uomGhostFreq>MHZ</uomGhostFreq>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>dme navaid</txtRmk>
          </Dme>
          <!-- NavigationalAid: [Marker:O] --- / MARKER NAVAID -->
          <Mkr>
            <MkrUid>
              <codeId>---</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
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
          <!-- NavigationalAid: [NDB:B] NNN / NDB NAVAID -->
          <Ndb>
            <NdbUid>
              <codeId>NNN</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </NdbUid>
            <OrgUid>
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
          <!-- NavigationalAid: [TACAN] TTT / TACAN NAVAID -->
          <Tcn>
            <TcnUid>
              <codeId>TTT</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </TcnUid>
            <OrgUid>
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
          <!-- NavigationalAid: [VOR:VOR] VVV / VOR NAVAID -->
          <Vor>
            <VorUid>
              <codeId>VVV</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </VorUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VOR NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [VOR:VOR] VDD / VOR/DME NAVAID -->
          <Vor>
            <VorUid>
              <codeId>VDD</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </VorUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [DME] VDD / VOR/DME NAVAID -->
          <Dme>
            <DmeUid>
              <codeId>VDD</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </DmeUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid>
              <codeId>VDD</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </VorUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Dme>
          <!-- NavigationalAid: [VOR:VOR] VTT / VORTAC NAVAID -->
          <Vor>
            <VorUid>
              <codeId>VTT</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </VorUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vortac navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [TACAN] VTT / VORTAC NAVAID -->
          <Tcn>
            <TcnUid>
              <codeId>VTT</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </TcnUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid>
              <codeId>VTT</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </VorUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeChannel>29X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ttt>
              <codeWorkHr>H24</codeWorkHr>
            </Ttt>
            <txtRmk>vortac navaid</txtRmk>
          </Tcn>
          <!-- Obstacle: [tower] 48.85825000N 002.29458889E EIFFEL TOWER -->
          <Obs>
            <ObsUid>
              <geoLat>485129.70N</geoLat>
              <geoLong>0021740.52E</geoLong>
            </ObsUid>
            <txtName>EIFFEL TOWER</txtName>
            <txtDescrType>TOWER</txtDescrType>
            <codeGroup>N</codeGroup>
            <codeLgt>Y</codeLgt>
            <txtDescrLgt>red strobes</txtDescrLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>2</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1187</valElev>
            <valElevAccuracy>3</valElevAccuracy>
            <valHgt>1063</valHgt>
            <uomDistVer>FT</uomDistVer>
            <txtRmk>Temporary light installations (white strobes, gyro light etc)</txtRmk>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67501389N 004.87256667E LA TEISSONIERE 1 -->
          <Obs>
            <ObsUid>
              <geoLat>444030.05N</geoLat>
              <geoLong>0045221.24E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 1</txtName>
            <txtDescrType>WINDTURBINE</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1764</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67946667N 004.87381111E LA TEISSONIERE 2 -->
          <Obs>
            <ObsUid>
              <geoLat>444046.08N</geoLat>
              <geoLong>0045225.72E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 2</txtName>
            <txtDescrType>WINDTURBINE</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1738</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
          <!-- Obstacle: [mast] 52.29639722N 002.10675278W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>521747.03N</geoLat>
              <geoLong>0020624.31W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <txtDescrType>MAST</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
          <!-- Obstacle: [mast] 52.29457778N 002.10568611W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>521740.48N</geoLat>
              <geoLong>0020620.47W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <txtDescrType>MAST</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
        </AIXM-Snapshot>
      END
    end
  end

  context "OFMX" do
    subject do
      AIXM.ofmx!
      AIXM::Factory.document
    end

    it "won't have errors" do
      _(subject.errors).must_equal []
    end

    it "builds correct OFMX" do
      _(subject.to_xml).must_equal <<~"END"
        <?xml version="1.0" encoding="UTF-8"?>
        <OFMX-Snapshot xmlns:xsi="http://schema.openflightmaps.org/0/OFMX-Snapshot.xsd" version="0" origin="rubygem aixm-#{AIXM::VERSION}" namespace="00000000-0000-0000-0000-000000000000" created="2018-01-01T12:00:00+01:00" effective="2018-01-01T12:00:00+01:00">
          <!-- Organisation: FRANCE -->
          <Org source="LF|GEN|0.0 FACTORY|0|0">
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <codeId>LF</codeId>
            <codeType>S</codeType>
            <txtRmk>Oversea departments not included</txtRmk>
          </Org>
          <!-- Unit: PUJAUT TWR -->
          <Uni source="LF|GEN|0.0 FACTORY|0|0">
            <UniUid region="LF">
              <txtName>PUJAUT</txtName>
              <codeType>TWR</codeType>
            </UniUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeClass>ICAO</codeClass>
            <txtRmk>FR only</txtRmk>
          </Uni>
          <!-- Service: APP by PUJAUT TWR -->
          <Ser>
            <SerUid>
              <UniUid region="LF">
                <txtName>PUJAUT</txtName>
                <codeType>TWR</codeType>
              </UniUid>
              <codeType>APP</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <Stt>
              <codeWorkHr>H24</codeWorkHr>
            </Stt>
            <txtRmk>service remarks</txtRmk>
          </Ser>
          <Fqy>
            <FqyUid>
              <SerUid>
                <UniUid region="LF">
                  <txtName>PUJAUT</txtName>
                  <codeType>TWR</codeType>
                </UniUid>
                <codeType>APP</codeType>
                <noSeq>1</noSeq>
              </SerUid>
              <valFreqTrans>123.35</valFreqTrans>
            </FqyUid>
            <valFreqRec>124.1</valFreqRec>
            <uomFreq>MHZ</uomFreq>
            <Ftt>
              <codeWorkHr>H24</codeWorkHr>
            </Ftt>
            <txtRmk>frequency remarks</txtRmk>
            <Cdl>
              <txtCallSign>PUJAUT CONTROL</txtCallSign>
              <codeLang>EN</codeLang>
            </Cdl>
            <Cdl>
              <txtCallSign>PUJAUT CONTROLE</txtCallSign>
              <codeLang>FR</codeLang>
            </Cdl>
          </Fqy>
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
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
            <AseUid region="LF">
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <codeSelAvbl>Y</codeSelAvbl>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid region="LF">
                <codeType>D</codeType>
                <codeId>PA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.90416667N</geoLatArc>
              <geoLongArc>007.56333333E</geoLongArc>
            </Avx>
            <Avx>
              <GbrUid>
                <txtName>FRANCE_GERMANY</txtName>
              </GbrUid>
              <codeType>FNT</codeType>
              <geoLat>47.94361111N</geoLat>
              <geoLong>007.59583333E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <!-- Airspace: [D] CIRCLE AIRSPACE -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
            <AseUid region="LF">
              <codeType>D</codeType>
              <codeId>CA</codeId>
            </AseUid>
            <txtLocalType>CIRCLE</txtLocalType>
            <txtName>CIRCLE AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <codeSelAvbl>Y</codeSelAvbl>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid region="LF">
                <codeType>D</codeType>
                <codeId>CA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.67326537N</geoLat>
              <geoLong>004.88333333E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.58333333N</geoLatArc>
              <geoLongArc>004.88333333E</geoLongArc>
            </Avx>
          </Abd>
          <!-- NavigationalAid: [DesignatedPoint:VFR-RP] DDD / DESIGNATED POINT NAVAID -->
          <Dpn source="LF|GEN|0.0 FACTORY|0|0">
            <DpnUid region="LF">
              <codeId>DDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DpnUid>
            <AhpUidAssoc region="LF">
              <codeId>LFNT</codeId>
            </AhpUidAssoc>
            <codeDatum>WGE</codeDatum>
            <codeType>VFR-RP</codeType>
            <txtName>DESIGNATED POINT NAVAID</txtName>
            <txtRmk>designated point navaid</txtRmk>
          </Dpn>
          <!-- NavigationalAid: [DME] MMM / DME NAVAID -->
          <Dme source="LF|GEN|0.0 FACTORY|0|0">
            <DmeUid region="LF">
              <codeId>MMM</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <valGhostFreq>114.8</valGhostFreq>
            <uomGhostFreq>MHZ</uomGhostFreq>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>dme navaid</txtRmk>
          </Dme>
          <!-- NavigationalAid: [Marker:O] --- / MARKER NAVAID -->
          <Mkr source="LF|GEN|0.0 FACTORY|0|0">
            <MkrUid region="LF">
              <codeId>---</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </MkrUid>
            <OrgUid region="LF">
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
          <!-- NavigationalAid: [NDB:B] NNN / NDB NAVAID -->
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
          <!-- NavigationalAid: [VOR:VOR] VVV / VOR NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VOR NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [VOR:VOR] VDD / VOR/DME NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF">
              <codeId>VDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [DME] VDD / VOR/DME NAVAID -->
          <Dme>
            <DmeUid region="LF">
              <codeId>VDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid region="LF">
              <codeId>VDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Dme>
          <!-- NavigationalAid: [VOR:VOR] VTT / VORTAC NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF">
              <codeId>VTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vortac navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [TACAN] VTT / VORTAC NAVAID -->
          <Tcn>
            <TcnUid region="LF">
              <codeId>VTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </TcnUid>
            <OrgUid region="LF">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid region="LF">
              <codeId>VTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeChannel>29X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ttt>
              <codeWorkHr>H24</codeWorkHr>
            </Ttt>
            <txtRmk>vortac navaid</txtRmk>
          </Tcn>
          <!-- Obstacle: [tower] 48.85825000N 002.29458889E EIFFEL TOWER -->
          <Obs source="LF|GEN|0.0 FACTORY|0|0">
            <ObsUid region="LF">
              <geoLat>48.85825000N</geoLat>
              <geoLong>002.29458889E</geoLong>
            </ObsUid>
            <txtName>EIFFEL TOWER</txtName>
            <codeType>TOWER</codeType>
            <codeLgt>Y</codeLgt>
            <txtDescrLgt>red strobes</txtDescrLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>2</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1187</valElev>
            <valElevAccuracy>3</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <valHgt>1063</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>88</valRadius>
            <uomRadius>M</uomRadius>
            <datetimeValidWef>2018-01-01T12:00:00+01:00</datetimeValidWef>
            <datetimeValidTil>2019-01-01T12:00:00+01:00</datetimeValidTil>
            <txtRmk>Temporary light installations (white strobes, gyro light etc)</txtRmk>
          </Obs>
          <!-- Obstacle group: MIRMANDE EOLIENNES -->
          <Ogr source="LF|GEN|0.0 FACTORY|0|0">
            <OgrUid region="LF">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </OgrUid>
            <txtName>MIRMANDE EOLIENNES</txtName>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElevAccuracy>33</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <txtRmk>Extension planned</txtRmk>
          </Ogr>
          <!-- Obstacle: [wind_turbine] 44.67501389N 004.87256667E LA TEISSONIERE 1 -->
          <Obs source="LF|GEN|0.0 FACTORY|0|0">
            <ObsUid region="LF">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </ObsUid>
            <OgrUid region="LF">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </OgrUid>
            <txtName>LA TEISSONIERE 1</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>1764</valElev>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67946667N 004.87381111E LA TEISSONIERE 2 -->
          <Obs source="LF|GEN|0.0 FACTORY|0|0">
            <ObsUid region="LF">
              <geoLat>44.67946667N</geoLat>
              <geoLong>004.87381111E</geoLong>
            </ObsUid>
            <OgrUid region="LF">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </OgrUid>
            <txtName>LA TEISSONIERE 2</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>1738</valElev>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle group: DROITWICH LONGWAVE ANTENNA -->
          <Ogr source="EG|GEN|0.0 FACTORY|0|0">
            <OgrUid region="EG">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </OgrUid>
            <txtName>DROITWICH LONGWAVE ANTENNA</txtName>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElevAccuracy>0</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <txtRmk>Destruction planned</txtRmk>
          </Ogr>
          <!-- Obstacle: [mast] 52.29639722N 002.10675278W DROITWICH LW NORTH -->
          <Obs source="EG|GEN|0.0 FACTORY|0|0">
            <ObsUid region="EG">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUid>
            <OgrUid region="EG">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </OgrUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>848</valElev>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle: [mast] 52.29457778N 002.10568611W DROITWICH LW NORTH -->
          <Obs source="EG|GEN|0.0 FACTORY|0|0">
            <ObsUid region="EG">
              <geoLat>52.29457778N</geoLat>
              <geoLong>002.10568611W</geoLong>
            </ObsUid>
            <OgrUid region="EG">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </OgrUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>848</valElev>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
            <ObsUidLink region="EG">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUidLink>
            <codeLinkType>CABLE</codeLinkType>
          </Obs>
        </OFMX-Snapshot>
      END
    end

    it "builds correct OFMX with mid" do
      AIXM.config.mid = true
      _(subject.to_xml).must_equal <<~"END"
        <?xml version="1.0" encoding="UTF-8"?>
        <OFMX-Snapshot xmlns:xsi="http://schema.openflightmaps.org/0/OFMX-Snapshot.xsd" version="0" origin="rubygem aixm-#{AIXM::VERSION}" namespace="00000000-0000-0000-0000-000000000000" created="2018-01-01T12:00:00+01:00" effective="2018-01-01T12:00:00+01:00">
          <!-- Organisation: FRANCE -->
          <Org source="LF|GEN|0.0 FACTORY|0|0">
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <codeId>LF</codeId>
            <codeType>S</codeType>
            <txtRmk>Oversea departments not included</txtRmk>
          </Org>
          <!-- Unit: PUJAUT TWR -->
          <Uni source="LF|GEN|0.0 FACTORY|0|0">
            <UniUid region="LF" mid="43032450-13e4-6f1a-728b-8ba8b5d31c92">
              <txtName>PUJAUT</txtName>
              <codeType>TWR</codeType>
            </UniUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeClass>ICAO</codeClass>
            <txtRmk>FR only</txtRmk>
          </Uni>
          <!-- Service: APP by PUJAUT TWR -->
          <Ser>
            <SerUid mid="6fcb48c9-10a7-db3a-68c2-405a9dfbcd30">
              <UniUid region="LF" mid="43032450-13e4-6f1a-728b-8ba8b5d31c92">
                <txtName>PUJAUT</txtName>
                <codeType>TWR</codeType>
              </UniUid>
              <codeType>APP</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <Stt>
              <codeWorkHr>H24</codeWorkHr>
            </Stt>
            <txtRmk>service remarks</txtRmk>
          </Ser>
          <Fqy>
            <FqyUid mid="30a9231c-9307-e4c4-5ddd-01315a3c0d42">
              <SerUid mid="6fcb48c9-10a7-db3a-68c2-405a9dfbcd30">
                <UniUid region="LF" mid="43032450-13e4-6f1a-728b-8ba8b5d31c92">
                  <txtName>PUJAUT</txtName>
                  <codeType>TWR</codeType>
                </UniUid>
                <codeType>APP</codeType>
                <noSeq>1</noSeq>
              </SerUid>
              <valFreqTrans>123.35</valFreqTrans>
            </FqyUid>
            <valFreqRec>124.1</valFreqRec>
            <uomFreq>MHZ</uomFreq>
            <Ftt>
              <codeWorkHr>H24</codeWorkHr>
            </Ftt>
            <txtRmk>frequency remarks</txtRmk>
            <Cdl>
              <txtCallSign>PUJAUT CONTROL</txtCallSign>
              <codeLang>EN</codeLang>
            </Cdl>
            <Cdl>
              <txtCallSign>PUJAUT CONTROLE</txtCallSign>
              <codeLang>FR</codeLang>
            </Cdl>
          </Fqy>
          <!-- Airport: LFNT AVIGNON-PUJAUT -->
          <Ahp source="LF|GEN|0.0 FACTORY|0|0">
            <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
              <codeId>LFNT</codeId>
            </AhpUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
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
            <RwyUid mid="b6d88198-7a6a-6e9b-d8ba-eb0aa00623d4">
              <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <txtRmk>Markings eroded</txtRmk>
          </Rwy>
          <Rdn>
            <RdnUid mid="2b0a1c24-c855-2ef9-ec1c-06dd9d321f2a">
              <RwyUid mid="b6d88198-7a6a-6e9b-d8ba-eb0aa00623d4">
                <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <RddUid mid="9628cdb7-f4bd-dff5-025c-d5f29521663b">
              <RdnUid mid="2b0a1c24-c855-2ef9-ec1c-06dd9d321f2a">
                <RwyUid mid="b6d88198-7a6a-6e9b-d8ba-eb0aa00623d4">
                  <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <RlsUid mid="29500769-112c-2480-6e88-5dbfc4976608">
              <RdnUid mid="2b0a1c24-c855-2ef9-ec1c-06dd9d321f2a">
                <RwyUid mid="b6d88198-7a6a-6e9b-d8ba-eb0aa00623d4">
                  <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <RdnUid mid="9a03514f-27fe-c2f6-dfd8-13eaa30b0d79">
              <RwyUid mid="b6d88198-7a6a-6e9b-d8ba-eb0aa00623d4">
                <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <RddUid mid="00d3bbbe-b6b1-772b-d5ee-61c0ac3caecd">
              <RdnUid mid="9a03514f-27fe-c2f6-dfd8-13eaa30b0d79">
                <RwyUid mid="b6d88198-7a6a-6e9b-d8ba-eb0aa00623d4">
                  <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <RlsUid mid="f64858b1-5ca1-2e28-f401-1198fbecaacc">
              <RdnUid mid="9a03514f-27fe-c2f6-dfd8-13eaa30b0d79">
                <RwyUid mid="b6d88198-7a6a-6e9b-d8ba-eb0aa00623d4">
                  <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <FtoUid mid="c4521dbc-7576-b1bf-4dc2-925d03d37774">
              <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <FdnUid mid="12f7708a-bc10-97fe-89b8-e78f4e7a8a4e">
              <FtoUid mid="c4521dbc-7576-b1bf-4dc2-925d03d37774">
                <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <FlsUid mid="ad207959-b96a-d958-432e-1f18483cfb64">
              <FdnUid mid="12f7708a-bc10-97fe-89b8-e78f4e7a8a4e">
                <FtoUid mid="c4521dbc-7576-b1bf-4dc2-925d03d37774">
                  <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <TlaUid mid="1a71faf5-ef1f-ebc9-bfc3-ac7dd50b172a">
              <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </TlaUid>
            <FtoUid mid="c4521dbc-7576-b1bf-4dc2-925d03d37774">
              <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <TlsUid mid="e0c705ef-275c-536a-55fc-5586b96752e4">
              <TlaUid mid="1a71faf5-ef1f-ebc9-bfc3-ac7dd50b172a">
                <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <AhuUid mid="131fb296-15d0-8f0f-1606-7a9e5645bbef">
              <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
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
            <AhaUid mid="ee455495-634c-dac4-dd9e-caf38f64f0ac">
              <AhpUid region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
                <codeId>LFNT</codeId>
              </AhpUid>
              <codeType>RADIO</codeType>
              <noSeq>1</noSeq>
            </AhaUid>
            <txtAddress>123.35 mhz</txtAddress>
            <txtRmk>A/A (callsign PUJAUT)</txtRmk>
          </Aha>
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
            <AseUid region="LF" mid="4fadb72f-7ee4-1171-3281-ac59b82dad86">
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <codeSelAvbl>Y</codeSelAvbl>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Abd>
            <AbdUid mid="56b399d5-59e8-64d7-d234-ea4856624b44">
              <AseUid region="LF" mid="4fadb72f-7ee4-1171-3281-ac59b82dad86">
                <codeType>D</codeType>
                <codeId>PA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.90416667N</geoLatArc>
              <geoLongArc>007.56333333E</geoLongArc>
            </Avx>
            <Avx>
              <GbrUid mid="7dc62c3c-87b9-05af-5386-5c3d39a2b324">
                <txtName>FRANCE_GERMANY</txtName>
              </GbrUid>
              <codeType>FNT</codeType>
              <geoLat>47.94361111N</geoLat>
              <geoLong>007.59583333E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <!-- Airspace: [D] CIRCLE AIRSPACE -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
            <AseUid region="LF" mid="69b199b2-931f-47ff-1e78-9fa796ec23b3">
              <codeType>D</codeType>
              <codeId>CA</codeId>
            </AseUid>
            <txtLocalType>CIRCLE</txtLocalType>
            <txtName>CIRCLE AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <codeSelAvbl>Y</codeSelAvbl>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Abd>
            <AbdUid mid="7082ac94-36bc-6d29-06d5-0b1f2a8bda50">
              <AseUid region="LF" mid="69b199b2-931f-47ff-1e78-9fa796ec23b3">
                <codeType>D</codeType>
                <codeId>CA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.67326537N</geoLat>
              <geoLong>004.88333333E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.58333333N</geoLatArc>
              <geoLongArc>004.88333333E</geoLongArc>
            </Avx>
          </Abd>
          <!-- NavigationalAid: [DesignatedPoint:VFR-RP] DDD / DESIGNATED POINT NAVAID -->
          <Dpn source="LF|GEN|0.0 FACTORY|0|0">
            <DpnUid region="LF" mid="36110542-bbfb-13e2-c819-7a0404be370a">
              <codeId>DDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DpnUid>
            <AhpUidAssoc region="LF" mid="af89d7b7-2ec0-902f-02ba-9e470e42d530">
              <codeId>LFNT</codeId>
            </AhpUidAssoc>
            <codeDatum>WGE</codeDatum>
            <codeType>VFR-RP</codeType>
            <txtName>DESIGNATED POINT NAVAID</txtName>
            <txtRmk>designated point navaid</txtRmk>
          </Dpn>
          <!-- NavigationalAid: [DME] MMM / DME NAVAID -->
          <Dme source="LF|GEN|0.0 FACTORY|0|0">
            <DmeUid region="LF" mid="cf8f4479-1b24-a9fb-59f5-95acd7de2012">
              <codeId>MMM</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <valGhostFreq>114.8</valGhostFreq>
            <uomGhostFreq>MHZ</uomGhostFreq>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>dme navaid</txtRmk>
          </Dme>
          <!-- NavigationalAid: [Marker:O] --- / MARKER NAVAID -->
          <Mkr source="LF|GEN|0.0 FACTORY|0|0">
            <MkrUid region="LF" mid="e84cdbf4-b564-5d09-e876-8c5e9bea8feb">
              <codeId>---</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </MkrUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
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
          <!-- NavigationalAid: [NDB:B] NNN / NDB NAVAID -->
          <Ndb source="LF|GEN|0.0 FACTORY|0|0">
            <NdbUid region="LF" mid="5514089c-e6a6-278e-4b1a-ace70db05769">
              <codeId>NNN</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </NdbUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
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
          <!-- NavigationalAid: [TACAN] TTT / TACAN NAVAID -->
          <Tcn source="LF|GEN|0.0 FACTORY|0|0">
            <TcnUid region="LF" mid="422eda8c-22b4-8a1c-98d4-e53a507d60e8">
              <codeId>TTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </TcnUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
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
          <!-- NavigationalAid: [VOR:VOR] VVV / VOR NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF" mid="0e8e1825-a33e-53eb-f305-528ff8b7ab92">
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VOR NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [VOR:VOR] VDD / VOR/DME NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF" mid="b62daf75-adfb-529a-2a40-8d488aa58bb4">
              <codeId>VDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [DME] VDD / VOR/DME NAVAID -->
          <Dme>
            <DmeUid region="LF" mid="b7472e9b-ffb7-8248-c481-def8ff81fe1f">
              <codeId>VDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid region="LF" mid="b62daf75-adfb-529a-2a40-8d488aa58bb4">
              <codeId>VDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <txtName>VOR/DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>vor/dme navaid</txtRmk>
          </Dme>
          <!-- NavigationalAid: [VOR:VOR] VTT / VORTAC NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid region="LF" mid="d594841e-9cc2-ac2f-cd47-2ff402d9f8c5">
              <codeId>VTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeType>VOR</codeType>
            <valFreq>111</valFreq>
            <uomFreq>MHZ</uomFreq>
            <codeTypeNorth>TRUE</codeTypeNorth>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Vtt>
              <codeWorkHr>H24</codeWorkHr>
            </Vtt>
            <txtRmk>vortac navaid</txtRmk>
          </Vor>
          <!-- NavigationalAid: [TACAN] VTT / VORTAC NAVAID -->
          <Tcn>
            <TcnUid region="LF" mid="d352502a-e804-601b-5528-d081e3b5161c">
              <codeId>VTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </TcnUid>
            <OrgUid region="LF" mid="971ba0a9-3714-12d5-d139-d26d5f1d6f25">
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid region="LF" mid="d594841e-9cc2-ac2f-cd47-2ff402d9f8c5">
              <codeId>VTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </VorUid>
            <txtName>VORTAC NAVAID</txtName>
            <codeChannel>29X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ttt>
              <codeWorkHr>H24</codeWorkHr>
            </Ttt>
            <txtRmk>vortac navaid</txtRmk>
          </Tcn>
          <!-- Obstacle: [tower] 48.85825000N 002.29458889E EIFFEL TOWER -->
          <Obs source="LF|GEN|0.0 FACTORY|0|0">
            <ObsUid region="LF" mid="04f75ef2-ffa3-2c72-8cf0-572b07b24541">
              <geoLat>48.85825000N</geoLat>
              <geoLong>002.29458889E</geoLong>
            </ObsUid>
            <txtName>EIFFEL TOWER</txtName>
            <codeType>TOWER</codeType>
            <codeLgt>Y</codeLgt>
            <txtDescrLgt>red strobes</txtDescrLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>2</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1187</valElev>
            <valElevAccuracy>3</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <valHgt>1063</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>88</valRadius>
            <uomRadius>M</uomRadius>
            <datetimeValidWef>2018-01-01T12:00:00+01:00</datetimeValidWef>
            <datetimeValidTil>2019-01-01T12:00:00+01:00</datetimeValidTil>
            <txtRmk>Temporary light installations (white strobes, gyro light etc)</txtRmk>
          </Obs>
          <!-- Obstacle group: MIRMANDE EOLIENNES -->
          <Ogr source="LF|GEN|0.0 FACTORY|0|0">
            <OgrUid region="LF" mid="2aede4b0-b8ad-e840-257e-743ee5c1325d">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </OgrUid>
            <txtName>MIRMANDE EOLIENNES</txtName>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElevAccuracy>33</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <txtRmk>Extension planned</txtRmk>
          </Ogr>
          <!-- Obstacle: [wind_turbine] 44.67501389N 004.87256667E LA TEISSONIERE 1 -->
          <Obs source="LF|GEN|0.0 FACTORY|0|0">
            <ObsUid region="LF" mid="79fcc46a-f585-18b0-501f-044b728f64f0">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </ObsUid>
            <OgrUid region="LF" mid="2aede4b0-b8ad-e840-257e-743ee5c1325d">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </OgrUid>
            <txtName>LA TEISSONIERE 1</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>1764</valElev>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67946667N 004.87381111E LA TEISSONIERE 2 -->
          <Obs source="LF|GEN|0.0 FACTORY|0|0">
            <ObsUid region="LF" mid="5268c531-41db-df17-4ea6-ed469e7e3630">
              <geoLat>44.67946667N</geoLat>
              <geoLong>004.87381111E</geoLong>
            </ObsUid>
            <OgrUid region="LF" mid="2aede4b0-b8ad-e840-257e-743ee5c1325d">
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </OgrUid>
            <txtName>LA TEISSONIERE 2</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>1738</valElev>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle group: DROITWICH LONGWAVE ANTENNA -->
          <Ogr source="EG|GEN|0.0 FACTORY|0|0">
            <OgrUid region="EG" mid="f8121392-e8b4-692b-e38e-fa5db2c0d702">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </OgrUid>
            <txtName>DROITWICH LONGWAVE ANTENNA</txtName>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElevAccuracy>0</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <txtRmk>Destruction planned</txtRmk>
          </Ogr>
          <!-- Obstacle: [mast] 52.29639722N 002.10675278W DROITWICH LW NORTH -->
          <Obs source="EG|GEN|0.0 FACTORY|0|0">
            <ObsUid region="EG" mid="2207a079-80e6-676f-6aa4-f39425e4c658">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUid>
            <OgrUid region="EG" mid="f8121392-e8b4-692b-e38e-fa5db2c0d702">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </OgrUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>848</valElev>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle: [mast] 52.29457778N 002.10568611W DROITWICH LW NORTH -->
          <Obs source="EG|GEN|0.0 FACTORY|0|0">
            <ObsUid region="EG" mid="d502a479-dfe5-8305-3546-ac73b42e555a">
              <geoLat>52.29457778N</geoLat>
              <geoLong>002.10568611W</geoLong>
            </ObsUid>
            <OgrUid region="EG" mid="f8121392-e8b4-692b-e38e-fa5db2c0d702">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </OgrUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>848</valElev>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
            <ObsUidLink region="EG" mid="2207a079-80e6-676f-6aa4-f39425e4c658">
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUidLink>
            <codeLinkType>CABLE</codeLinkType>
          </Obs>
        </OFMX-Snapshot>
      END
    end
  end
end
