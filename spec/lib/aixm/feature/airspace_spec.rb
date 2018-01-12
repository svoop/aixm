require_relative '../../../spec_helper'

describe AIXM::Feature::Airspace do
  context "incomplete" do
    subject do
      AIXM::Feature::Airspace.new(name: 'foobar', type: 'D')
    end

    it "must fail validation" do
      subject.wont_be :valid?
    end

    describe :vertical_limits= do
      it "won't accept invalid vertical limits" do
        -> { subject.vertical_limits=0 }.must_raise ArgumentError
      end
    end
  end

  context "complete" do
    subject do
      AIXM::Factory.airspace
    end

    it "must pass validation" do
      subject.must_be :valid?
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal '5b8e650b'
      end
    end

    it "must build correct XML" do
      subject.to_xml.must_equal '<Ase xt_classLayersAvail="false"><AseUid mid="5b8e650b" newEntity="true"><codeType>D</codeType></AseUid><txtName>foobar</txtName><codeDistVerUpper>STD</codeDistVerUpper><valDistVerUpper>65</valDistVerUpper><uomDistVerUpper>FL</uomDistVerUpper><codeDistVerLower>STD</codeDistVerLower><valDistVerLower>45</valDistVerLower><uomDistVerLower>FL</uomDistVerLower><codeDistVerMax>ALT</codeDistVerMax><valDistVerMax>6000</valDistVerMax><uomDistVerMax>FT</uomDistVerMax><codeDistVerMnm>HEI</codeDistVerMnm><valDistVerMnm>3000</valDistVerMnm><uomDistVerMnm>FT</uomDistVerMnm><xt_txtRmk>airborn pink elephants</xt_txtRmk><xt_selAvail>false</xt_selAvail></Ase><Abd><AbdUid><AseUid mid="5b8e650b" newEntity="true"><codeType>D</codeType></AseUid></AbdUid><Avx><codeType>GRC</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>22.00000000N</geoLat><geoLong>33.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>33.00000000N</geoLat><geoLong>44.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong></Avx></Abd>'
    end
  end
end
