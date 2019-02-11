require_relative '../../spec_helper'

describe AIXM::Document do
  subject do
    AIXM.document
  end

  describe :initialize do
    it "sets defaults" do
      subject.features.must_equal []
    end
  end

  describe :namespace= do
    it "fails on invalid values" do
      ['foobar', :foobar].wont_be_written_to subject, :namespace
    end

    it "sets random UUID for nil value" do
      subject.tap { |s| s.namespace = nil }.namespace.must_match AIXM::Document::NAMESPACE_RE
    end

    it "accepts UUID value" do
      [SecureRandom.uuid].must_be_written_to subject, :namespace
    end
  end

  describe :created_at= do
    it "fails on invalid values" do
      ['foobar', '2018-01-77'].wont_be_written_to subject, :created_at
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      subject.tap { |s| s.created_at = string }.created_at.must_equal Time.parse(string)
    end

    it "falls back to effective_at first" do
      subject.effective_at = Time.now
      subject.created_at = nil
      subject.created_at.must_equal subject.effective_at
    end

    it "falls back to now second" do
      subject.created_at = nil
      subject.created_at.must_be_close_to Time.now
    end
  end

  describe :effective_at= do
    it "fails on invalid values" do
      ['foobar', '2018-01-77'].wont_be_written_to subject, :effective_at
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      subject.tap { |s| s.effective_at = string }.effective_at.must_equal Time.parse(string)
    end

    it "falls back to created_at first" do
      subject.effective_at = Time.now
      subject.effective_at = nil
      subject.effective_at.must_equal subject.created_at
    end

    it "falls back to now second" do
      subject.effective_at = nil
      subject.effective_at.must_be_close_to Time.now
    end
  end

  context "AIXM" do
    subject do
      AIXM.aixm!
      AIXM::Factory.document
    end

    it "won't have errors" do
      subject.errors.must_equal []
    end

    it "builds correct AIXM" do
      subject.to_xml.must_equal <<~"END"
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
              <txtName>PUJAUT TWR</txtName>
            </UniUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeType>TWR</codeType>
            <codeClass>ICAO</codeClass>
            <txtRmk>A/A FR only</txtRmk>
          </Uni>
          <Ser>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT TWR</txtName>
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
                  <txtName>PUJAUT TWR</txtName>
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
            <valMagBrg>166</valMagBrg>
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
            <valMagBrg>346</valMagBrg>
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
          <Tla>
            <TlaUid>
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </TlaUid>
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
            <txtPcnNote>Cracks near the center.</txtPcnNote>
            <codeSts>OTHER</codeSts>
            <txtRmk>Authorizaton by AD operator required</txtRmk>
          </Tla>
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
      subject.errors.must_equal []
    end

    it "builds correct OFMX" do
      subject.to_xml.must_equal <<~"END"
        <?xml version="1.0" encoding="UTF-8"?>
        <OFMX-Snapshot xmlns:xsi="http://schema.openflightmaps.org/0/OFMX-Snapshot.xsd" version="0" origin="rubygem aixm-#{AIXM::VERSION}" region="LF" namespace="00000000-0000-0000-0000-000000000000" created="2018-01-01T12:00:00+01:00" effective="2018-01-01T12:00:00+01:00">
          <!-- Organisation: FRANCE -->
          <Org source="LF|GEN|0.0 FACTORY|0|0">
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <codeId>LF</codeId>
            <codeType>S</codeType>
            <txtRmk>Oversea departments not included</txtRmk>
          </Org>
          <!-- Unit: PUJAUT TWR -->
          <Uni source="LF|GEN|0.0 FACTORY|0|0">
            <UniUid>
              <txtName>PUJAUT TWR</txtName>
            </UniUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <codeType>TWR</codeType>
            <codeClass>ICAO</codeClass>
            <txtRmk>A/A FR only</txtRmk>
          </Uni>
          <Ser>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT TWR</txtName>
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
                  <txtName>PUJAUT TWR</txtName>
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
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <OrgUid>
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
            <geoLat>44.00211944N</geoLat>
            <geoLong>004.75216944E</geoLong>
            <valTrueBrg>165</valTrueBrg>
            <valMagBrg>166</valMagBrg>
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
            <geoLat>43.99036389N</geoLat>
            <geoLong>004.75645556E</geoLong>
            <valTrueBrg>345</valTrueBrg>
            <valMagBrg>346</valMagBrg>
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
          <Tla>
            <TlaUid>
              <AhpUid>
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
            <codeComposition>CONC</codeComposition>
            <codePreparation>PAVED</codePreparation>
            <codeCondSfc>FAIR</codeCondSfc>
            <valPcnClass>30</valPcnClass>
            <codePcnPavementType>F</codePcnPavementType>
            <codePcnPavementSubgrade>A</codePcnPavementSubgrade>
            <codePcnMaxTirePressure>W</codePcnMaxTirePressure>
            <codePcnEvalMethod>U</codePcnEvalMethod>
            <txtPcnNote>Cracks near the center.</txtPcnNote>
            <codeSts>OTHER</codeSts>
            <txtRmk>Authorizaton by AD operator required</txtRmk>
          </Tla>
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
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
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
            <codeSelAvbl>Y</codeSelAvbl>
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
            <codeSelAvbl>Y</codeSelAvbl>
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
              <geoLat>47.67326537N</geoLat>
              <geoLong>004.88333333E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.58333333N</geoLatArc>
              <geoLongArc>004.88333333E</geoLongArc>
            </Avx>
          </Abd>
          <!-- NavigationalAid: [DesignatedPoint:VFR-RP] DDD / DESIGNATED POINT NAVAID -->
          <Dpn source="LF|GEN|0.0 FACTORY|0|0">
            <DpnUid>
              <codeId>DDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DpnUid>
            <AhpUidAssoc>
              <codeId>LFNT</codeId>
            </AhpUidAssoc>
            <codeDatum>WGE</codeDatum>
            <codeType>VFR-RP</codeType>
            <txtName>DESIGNATED POINT NAVAID</txtName>
            <txtRmk>designated point navaid</txtRmk>
          </Dpn>
          <!-- NavigationalAid: [DME] MMM / DME NAVAID -->
          <Dme source="LF|GEN|0.0 FACTORY|0|0">
            <DmeUid>
              <codeId>MMM</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
          <!-- NavigationalAid: [NDB:B] NNN / NDB NAVAID -->
          <Ndb source="LF|GEN|0.0 FACTORY|0|0">
            <NdbUid>
              <codeId>NNN</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
          <!-- NavigationalAid: [VOR:VOR] VVV / VOR NAVAID -->
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid>
              <codeId>VVV</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
          <Vor source="LF|GEN|0.0 FACTORY|0|0">
            <VorUid>
              <codeId>VDD</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </DmeUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid>
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
            <VorUid>
              <codeId>VTT</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
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
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
            </TcnUid>
            <OrgUid>
              <txtName>FRANCE</txtName>
            </OrgUid>
            <VorUid>
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
          <Obs>
            <ObsUid>
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
            <valHgt>1063</valHgt>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>88</valRadius>
            <uomRadius>M</uomRadius>
            <datetimeValidWef>2018-01-01T12:00:00+01:00</datetimeValidWef>
            <datetimeValidTil>2019-01-01T12:00:00+01:00</datetimeValidTil>
            <txtRmk>Temporary light installations (white strobes, gyro light etc)</txtRmk>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67501389N 004.87256667E LA TEISSONIERE 1 -->
          <Obs>
            <ObsUid>
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 1</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1764</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>462c8d00-981a-0995-09aa-4ba39161bb41</codeGroupId>
            <txtGroupName>MIRMANDE EOLIENNES</txtGroupName>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67946667N 004.87381111E LA TEISSONIERE 2 -->
          <Obs>
            <ObsUid>
              <geoLat>44.67946667N</geoLat>
              <geoLong>004.87381111E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 2</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1738</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>462c8d00-981a-0995-09aa-4ba39161bb41</codeGroupId>
            <txtGroupName>MIRMANDE EOLIENNES</txtGroupName>
          </Obs>
          <!-- Obstacle: [mast] 52.29639722N 002.10675278W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>18e65683-798d-0941-8de4-cb65a6427035</codeGroupId>
            <txtGroupName>DROITWICH LONGWAVE ANTENNA</txtGroupName>
          </Obs>
          <!-- Obstacle: [mast] 52.29457778N 002.10568611W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>52.29457778N</geoLat>
              <geoLong>002.10568611W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>18e65683-798d-0941-8de4-cb65a6427035</codeGroupId>
            <txtGroupName>DROITWICH LONGWAVE ANTENNA</txtGroupName>
            <ObsUidLink>
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
