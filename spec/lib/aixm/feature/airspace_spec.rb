require_relative '../../../spec_helper'

describe AIXM::Feature::Airspace do
  context "incomplete" do
    subject do
      AIXM::Feature::Airspace.new(name: 'foobar', type: 'D')
    end

    describe :valid? do
      it "must fail validation" do
        subject.wont_be :valid?
      end
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

    describe :valid? do
      it "must pass validation" do
        subject.must_be :valid?
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 'B022C1B8'
      end
    end

    describe :to_xml do
      it "must build correct XML with OFM extensions" do
        subject.to_xml(:ofm).must_equal <<~END
          <Ase xt_classLayersAvail="false">
            <AseUid mid="B022C1B8" newEntity="true">
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
            <xt_txtRmk>airborn pink elephants</xt_txtRmk>
            <xt_selAvail>false</xt_selAvail>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="B022C1B8" newEntity="true">
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
        END
      end
    end
  end
end
