require_relative '../../spec_helper'

describe AIXM::Document do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM::Document.new(created_at: 0) }.must_raise ArgumentError
      -> { AIXM::Document.new(created_at: 'foobar') }.must_raise ArgumentError
      -> { AIXM::Document.new(effective_at: 0) }.must_raise ArgumentError
      -> { AIXM::Document.new(effective_at: 'foobar') }.must_raise ArgumentError
    end

    it "must accept strings" do
      string = '2018-01-01 12:00:00 +0100'
      AIXM::Document.new(created_at: string).created_at.must_equal Time.parse(string)
      AIXM::Document.new(effective_at: string).effective_at.must_equal Time.parse(string)
    end

    it "must accept dates" do
      date = Date.parse('2018-01-01')
      AIXM::Document.new(created_at: date).created_at.must_equal date.to_time
      AIXM::Document.new(effective_at: date).effective_at.must_equal date.to_time
    end

    it "must accept times" do
      time = Time.parse('2018-01-01 12:00:00 +0100')
      AIXM::Document.new(created_at: time).created_at.must_equal time
      AIXM::Document.new(effective_at: time).effective_at.must_equal time
    end

    it "must accept nils" do
      AIXM::Document.new(created_at: nil).created_at.must_be :nil?
      AIXM::Document.new(effective_at: nil).effective_at.must_be :nil?
    end
  end

  context "incomplete" do
    subject do
      AIXM::Document.new
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
          <Ase>
            <AseUid mid="21074887">
              <codeType>D</codeType>
              <codeId>21074887</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
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
              <AseUid mid="21074887">
                <codeType>D</codeType>
                <codeId>21074887</codeId>
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
          <Ase>
            <AseUid mid="49057596">
              <codeType>D</codeType>
              <codeId>49057596</codeId>
            </AseUid>
            <txtLocalType>CIRCLE</txtLocalType>
            <txtName>CIRCLE AIRSPACE</txtName>
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
              <AseUid mid="49057596">
                <codeType>D</codeType>
                <codeId>49057596</codeId>
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
        </AIXM-Snapshot>
      END
    end

    it "must build correct XML with OFM extensions" do
      subject.to_xml(:OFM).must_equal <<~"END"
        <?xml version="1.0" encoding="UTF-8"?>
        <AIXM-Snapshot xmlns:xsi="http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd" version="4.5 + OFM extensions of version 0.1" origin="AIXM 0.1.1 Ruby gem" created="2018-01-18T12:00:00+01:00" effective="2018-01-18T12:00:00+01:00">
          <Ase xt_classLayersAvail="false">
            <AseUid mid="21074887" newEntity="true">
              <codeType>D</codeType>
              <codeId>21074887</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
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
              <AseUid mid="21074887" newEntity="true">
                <codeType>D</codeType>
                <codeId>21074887</codeId>
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
          <Ase xt_classLayersAvail="false">
            <AseUid mid="49057596" newEntity="true">
              <codeType>D</codeType>
              <codeId>49057596</codeId>
            </AseUid>
            <txtLocalType>CIRCLE</txtLocalType>
            <txtName>CIRCLE AIRSPACE</txtName>
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
              <AseUid mid="49057596" newEntity="true">
                <codeType>D</codeType>
                <codeId>49057596</codeId>
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
        </AIXM-Snapshot>
      END
    end
  end
end
