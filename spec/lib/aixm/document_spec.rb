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
      AIXM::Document.new.tap do |document|
        document << AIXM::Factory.airspace
        document << AIXM::Factory.airspace
      end
    end

    it "must pass validation" do
      subject.must_be :valid?
    end

    it "must build correct XML" do
      subject.to_xml.must_equal '<?xml version="1.0" encoding="UTF-8"?><AIXM-Snapshot xsi="http://www.aixm.aero/schema/4.5/AIXM-Snapshot.xsd" version="4.5 + OFM extensions of version 0.1" origin="AIXM 0.1.0 Ruby gem" created="2018-01-12T12:47:37+01:00" effective="2018-01-12T12:47:37+01:00"><Ase xt_classLayersAvail="false"><AseUid mid="46057278" newEntity="true"><codeType>D</codeType></AseUid><txtName>foobar</txtName><codeDistVerUpper>STD</codeDistVerUpper><valDistVerUpper>65</valDistVerUpper><uomDistVerUpper>FL</uomDistVerUpper><codeDistVerLower>STD</codeDistVerLower><valDistVerLower>45</valDistVerLower><uomDistVerLower>FL</uomDistVerLower><codeDistVerMax>ALT</codeDistVerMax><valDistVerMax>6000</valDistVerMax><uomDistVerMax>FT</uomDistVerMax><codeDistVerMnm>HEI</codeDistVerMnm><valDistVerMnm>3000</valDistVerMnm><uomDistVerMnm>FT</uomDistVerMnm><xt_txtRmk>airborn pink elephants</xt_txtRmk><xt_selAvail>false</xt_selAvail></Ase><Abd><AbdUid><AseUid mid="46057278" newEntity="true"><codeType>D</codeType></AseUid></AbdUid><Avx><codeType>GRC</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>22.00000000N</geoLat><geoLong>33.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>33.00000000N</geoLat><geoLong>44.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong></Avx></Abd><Ase xt_classLayersAvail="false"><AseUid mid="66fb750b" newEntity="true"><codeType>D</codeType></AseUid><txtName>foobar</txtName><codeDistVerUpper>STD</codeDistVerUpper><valDistVerUpper>65</valDistVerUpper><uomDistVerUpper>FL</uomDistVerUpper><codeDistVerLower>STD</codeDistVerLower><valDistVerLower>45</valDistVerLower><uomDistVerLower>FL</uomDistVerLower><codeDistVerMax>ALT</codeDistVerMax><valDistVerMax>6000</valDistVerMax><uomDistVerMax>FT</uomDistVerMax><codeDistVerMnm>HEI</codeDistVerMnm><valDistVerMnm>3000</valDistVerMnm><uomDistVerMnm>FT</uomDistVerMnm><xt_txtRmk>airborn pink elephants</xt_txtRmk><xt_selAvail>false</xt_selAvail></Ase><Abd><AbdUid><AseUid mid="66fb750b" newEntity="true"><codeType>D</codeType></AseUid></AbdUid><Avx><codeType>GRC</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>22.00000000N</geoLat><geoLong>33.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>33.00000000N</geoLat><geoLong>44.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong></Avx></Abd></AIXM-Snapshot>'
    end
  end
end
