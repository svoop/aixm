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
            <AseUid mid="B022C1B8">
              <codeType>D</codeType>
              <codeId>B022C1B8</codeId>
            </AseUid>
            <txtName>FOOBAR</txtName>
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
            <txtRmk>airborn pink elephants</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="B022C1B8">
                <codeType>D</codeType>
                <codeId>B022C1B8</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>220000.00N</geoLat>
              <geoLong>0330000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>330000.00N</geoLat>
              <geoLong>0440000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <Ase>
            <AseUid mid="B022C1B8">
              <codeType>D</codeType>
              <codeId>B022C1B8</codeId>
            </AseUid>
            <txtName>FOOBAR</txtName>
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
            <txtRmk>airborn pink elephants</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="B022C1B8">
                <codeType>D</codeType>
                <codeId>B022C1B8</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>220000.00N</geoLat>
              <geoLong>0330000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>330000.00N</geoLat>
              <geoLong>0440000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
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
            <AseUid mid="B022C1B8">
              <codeType>D</codeType>
              <codeId>B022C1B8</codeId>
            </AseUid>
            <txtName>FOOBAR</txtName>
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
            <txtRmk>airborn pink elephants</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="B022C1B8">
                <codeType>D</codeType>
                <codeId>B022C1B8</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>220000.00N</geoLat>
              <geoLong>0330000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>330000.00N</geoLat>
              <geoLong>0440000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <Ase>
            <AseUid mid="B022C1B8">
              <codeType>D</codeType>
              <codeId>B022C1B8</codeId>
            </AseUid>
            <txtName>FOOBAR</txtName>
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
            <txtRmk>airborn pink elephants</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="B022C1B8">
                <codeType>D</codeType>
                <codeId>B022C1B8</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>220000.00N</geoLat>
              <geoLong>0330000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>330000.00N</geoLat>
              <geoLong>0440000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>110000.00N</geoLat>
              <geoLong>0220000.00E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
        </AIXM-Snapshot>
      END
    end
  end
end
