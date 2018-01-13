require_relative '../../spec_helper'

describe AIXM::Document do
  context "incomplete" do
    subject do
      AIXM::Document.new
    end

    it "must fail validation" do
      subject.wont_be :valid?
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
      subject.must_be :valid?
    end

    it "must build correct XML without extensions" do
      subject.to_xml.must_equal <<~END
        <?xml version="1.0" encoding="UTF-8"?>
        <AIXM-Snapshot xmlns:xsi="http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd" version="4.5" origin="AIXM 0.1.0 Ruby gem" created="2018-01-18T12:00:00+01:00" effective="2018-01-18T12:00:00+01:00">
          <Ase>
            <AseUid mid="7F466CA0">
              <codeType>D</codeType>
              <codeId>7F466CA0</codeId>
            </AseUid>
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
            <txtRmk>polygon airspace</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="7F466CA0">
                <codeType>D</codeType>
                <codeId>7F466CA0</codeId>
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
              <GbrUid>
                <txtName>foobar</txtName>
              </GbrUid>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <Ase>
            <AseUid mid="E1115E8A">
              <codeType>D</codeType>
              <codeId>E1115E8A</codeId>
            </AseUid>
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
            <txtRmk>circle airspace</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="E1115E8A">
                <codeType>D</codeType>
                <codeId>E1115E8A</codeId>
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
      subject.to_xml(:OFM).must_equal <<~END
        <?xml version="1.0" encoding="UTF-8"?>
        <AIXM-Snapshot xmlns:xsi="http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd" version="4.5 + OFM extensions of version 0.1" origin="AIXM 0.1.0 Ruby gem" created="2018-01-18T12:00:00+01:00" effective="2018-01-18T12:00:00+01:00">
          <Ase>
            <AseUid mid="7F466CA0">
              <codeType>D</codeType>
              <codeId>7F466CA0</codeId>
            </AseUid>
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
            <txtRmk>polygon airspace</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="7F466CA0">
                <codeType>D</codeType>
                <codeId>7F466CA0</codeId>
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
              <GbrUid>
                <txtName>foobar</txtName>
              </GbrUid>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>475133.00N</geoLat>
              <geoLong>0073336.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <Ase>
            <AseUid mid="E1115E8A">
              <codeType>D</codeType>
              <codeId>E1115E8A</codeId>
            </AseUid>
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
            <txtRmk>circle airspace</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="E1115E8A">
                <codeType>D</codeType>
                <codeId>E1115E8A</codeId>
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
  end
end
