require_relative '../../spec_helper'

describe AIXM::Document do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM.document(created_at: 0) }.must_raise ArgumentError
      -> { AIXM.document(created_at: 'foobar') }.must_raise ArgumentError
      -> { AIXM.document(effective_at: 0) }.must_raise ArgumentError
      -> { AIXM.document(effective_at: 'foobar') }.must_raise ArgumentError
    end

    it "must accept strings" do
      string = '2018-01-01 12:00:00 +0100'
      AIXM.document(created_at: string).created_at.must_equal Time.parse(string)
      AIXM.document(effective_at: string).effective_at.must_equal Time.parse(string)
    end

    it "must accept dates" do
      date = Date.parse('2018-01-01')
      AIXM.document(created_at: date).created_at.must_equal date.to_time
      AIXM.document(effective_at: date).effective_at.must_equal date.to_time
    end

    it "must accept times" do
      time = Time.parse('2018-01-01 12:00:00 +0100')
      AIXM.document(created_at: time).created_at.must_equal time
      AIXM.document(effective_at: time).effective_at.must_equal time
    end

    it "must accept nils" do
      AIXM.document(created_at: nil).created_at.must_be :nil?
      AIXM.document(effective_at: nil).effective_at.must_be :nil?
    end
  end

  context "incomplete" do
    subject do
      AIXM.document
    end

    it "must fail validation" do
      subject.wont_be :complete?
    end
  end

  context "complete" do
    subject do
      AIXM::Factory.document
    end

    it "won't have errors" do
      subject.errors.must_equal []
    end

    it "must pass validation" do
      subject.must_be :complete?
    end

    it "must build correct XML without extensions" do
      subject.to_xml.must_equal <<~"END"
        <?xml version="1.0" encoding="UTF-8"?>
        <AIXM-Snapshot xmlns:xsi="http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd" version="4.5" origin="AIXM #{AIXM::VERSION} Ruby gem" created="2018-01-18T12:00:00+01:00" effective="2018-01-18T12:00:00+01:00">
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase>
            <AseUid mid="367297292">
              <codeType>D</codeType>
              <codeId>367297292</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
            <codeClass>C</codeClass>
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
            <txtRmk>polygon airspace</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="367297292">
                <codeType>D</codeType>
                <codeId>367297292</codeId>
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
            <AseUid mid="332058082">
              <codeType>D</codeType>
              <codeId>332058082</codeId>
            </AseUid>
            <txtLocalType>CIRCLE</txtLocalType>
            <txtName>CIRCLE AIRSPACE</txtName>
            <codeClass>C</codeClass>
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
            <txtRmk>circle airspace</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="332058082">
                <codeType>D</codeType>
                <codeId>332058082</codeId>
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
          <!-- Navigational aid: [DesignatedPoint:ICAO] DESIGNATED POINT NAVAID -->
          <Dpn>
            <DpnUid>
              <codeId>DPN</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </DpnUid>
            <OrgUid/>
            <txtName>DESIGNATED POINT NAVAID</txtName>
            <codeDatum>WGE</codeDatum>
            <codeType>ICAO</codeType>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>designated point navaid</txtRmk>
          </Dpn>
          <!-- Navigational aid: [DME] DME NAVAID -->
          <Dme>
            <DmeUid>
              <codeId>DME</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </DmeUid>
            <OrgUid/>
            <txtName>DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>dme navaid</txtRmk>
          </Dme>
          <!-- Navigational aid: [Marker] MARKER NAVAID -->
          <Mkr>
            <MkrUid>
              <codeId>---</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </MkrUid>
            <OrgUid/>
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
          <!-- Navigational aid: [NDB] NDB NAVAID -->
          <Ndb>
            <NdbUid>
              <codeId>NDB</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </NdbUid>
            <OrgUid/>
            <txtName>NDB NAVAID</txtName>
            <valFreq>555</valFreq>
            <uomFreq>KHZ</uomFreq>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ntt>
              <codeWorkHr>H24</codeWorkHr>
            </Ntt>
            <txtRmk>ndb navaid</txtRmk>
          </Ndb>
          <!-- Navigational aid: [TACAN] TACAN NAVAID -->
          <Tcn>
            <TcnUid>
              <codeId>TCN</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
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
          <!-- Navigational aid: [VOR:VOR] VOR NAVAID -->
          <Vor>
            <VorUid>
              <codeId>VOR</codeId>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
            </VorUid>
            <OrgUid/>
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
        </AIXM-Snapshot>
      END
    end

    it "must build correct XML with OFM extensions" do
      subject.to_xml(:ofm).must_equal <<~"END"
        <?xml version="1.0" encoding="UTF-8"?>
        <AIXM-Snapshot xmlns:xsi="http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd" version="4.5 + OFM extensions of version 0.1" origin="AIXM #{AIXM::VERSION} Ruby gem" created="2018-01-18T12:00:00+01:00" effective="2018-01-18T12:00:00+01:00">
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase xt_classLayersAvail="false">
            <AseUid mid="367297292" newEntity="true">
              <codeType>D</codeType>
              <codeId>367297292</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
            <codeClass>C</codeClass>
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
            <txtRmk>polygon airspace</txtRmk>
            <xt_selAvail>false</xt_selAvail>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="367297292" newEntity="true">
                <codeType>D</codeType>
                <codeId>367297292</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.90416667N</geoLatArc>
              <geoLongArc>7.56333333E</geoLongArc>
            </Avx>
            <Avx>
              <codeType>FNT</codeType>
              <geoLat>47.94361111N</geoLat>
              <geoLong>7.59583333E</geoLong>
              <codeDatum>WGE</codeDatum>
              <GbrUid>
                <txtName>FRANCE_GERMANY</txtName>
              </GbrUid>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <!-- Airspace: [D] CIRCLE AIRSPACE -->
          <Ase xt_classLayersAvail="false">
            <AseUid mid="332058082" newEntity="true">
              <codeType>D</codeType>
              <codeId>332058082</codeId>
            </AseUid>
            <txtLocalType>CIRCLE</txtLocalType>
            <txtName>CIRCLE AIRSPACE</txtName>
            <codeClass>C</codeClass>
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
            <txtRmk>circle airspace</txtRmk>
            <xt_selAvail>false</xt_selAvail>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="332058082" newEntity="true">
                <codeType>D</codeType>
                <codeId>332058082</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.67326549N</geoLat>
              <geoLong>4.88333333E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.58333333N</geoLatArc>
              <geoLongArc>4.88333333E</geoLongArc>
            </Avx>
          </Abd>
          <!-- Navigational aid: [DesignatedPoint:ICAO] DESIGNATED POINT NAVAID -->
          <Dpn>
            <DpnUid newEntity="true">
              <codeId>DPN</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </DpnUid>
            <OrgUid/>
            <txtName>DESIGNATED POINT NAVAID</txtName>
            <codeDatum>WGE</codeDatum>
            <codeType>ICAO</codeType>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>designated point navaid</txtRmk>
          </Dpn>
          <!-- Navigational aid: [DME] DME NAVAID -->
          <Dme>
            <DmeUid newEntity="true">
              <codeId>DME</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </DmeUid>
            <OrgUid/>
            <txtName>DME NAVAID</txtName>
            <codeChannel>95X</codeChannel>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Dtt>
              <codeWorkHr>H24</codeWorkHr>
            </Dtt>
            <txtRmk>dme navaid</txtRmk>
          </Dme>
          <!-- Navigational aid: [Marker] MARKER NAVAID -->
          <Mkr>
            <MkrUid newEntity="true">
              <codeId>---</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </MkrUid>
            <OrgUid/>
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
          <!-- Navigational aid: [NDB] NDB NAVAID -->
          <Ndb>
            <NdbUid newEntity="true">
              <codeId>NDB</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </NdbUid>
            <OrgUid/>
            <txtName>NDB NAVAID</txtName>
            <valFreq>555</valFreq>
            <uomFreq>KHZ</uomFreq>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Ntt>
              <codeWorkHr>H24</codeWorkHr>
            </Ntt>
            <txtRmk>ndb navaid</txtRmk>
          </Ndb>
          <!-- Navigational aid: [TACAN] TACAN NAVAID -->
          <Tcn>
            <TcnUid newEntity="true">
              <codeId>TCN</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
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
          <!-- Navigational aid: [VOR:VOR] VOR NAVAID -->
          <Vor>
            <VorUid newEntity="true">
              <codeId>VOR</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </VorUid>
            <OrgUid/>
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
        </AIXM-Snapshot>
      END
    end
  end
end
