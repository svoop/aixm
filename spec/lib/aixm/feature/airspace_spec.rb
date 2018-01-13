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
      AIXM::Factory.polygon_airspace
    end

    describe :valid? do
      it "must pass validation" do
        subject.must_be :valid?
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal '7F466CA0'
      end
    end

    describe :to_xml do
      it "must build correct XML with OFM extensions" do
        subject.to_xml(:OFM).must_equal <<~END
          <Ase xt_classLayersAvail="false">
            <AseUid mid="7F466CA0" newEntity="true">
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
            <xt_txtRmk>polygon airspace</xt_txtRmk>
            <xt_selAvail>false</xt_selAvail>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid mid="7F466CA0" newEntity="true">
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
        END
      end
    end
  end
end
