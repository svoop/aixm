require_relative '../../../spec_helper'

describe AIXM::Feature::Airspace do
  context "incomplete" do
    subject do
      AIXM::Feature::Airspace.new(name: 'foobar', type: 'D')
    end

    describe :complete? do
      it "must fail validation" do
        subject.wont_be :complete?
      end
    end

    describe :vertical_limits= do
      it "won't accept invalid vertical limits" do
        -> { subject.vertical_limits = 0 }.must_raise ArgumentError
      end
    end
  end

  context "complete" do
    subject do
      AIXM::Factory.polygon_airspace
    end

    describe :complete? do
      it "must pass validation" do
        subject.must_be :complete?
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 'B8B2E175'
      end
    end

    describe :to_xml do
      it "must build correct XML with OFM extensions" do
        digest = subject.to_digest
        subject.to_xml(:OFM).must_equal <<~"END"
          <Ase xt_classLayersAvail="false">
            <AseUid mid="#{digest}" newEntity="true">
              <codeType>D</codeType>
              <codeId>#{digest}</codeId>
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
              <AseUid mid="#{digest}" newEntity="true">
                <codeType>D</codeType>
                <codeId>#{digest}</codeId>
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
        END
      end
    end

    context "partially complete" do
      it "must build correct XML without short name" do
        subject = AIXM::Factory.polygon_airspace(short_name: nil)
        subject.to_xml.wont_match(/txtLocalType/)
      end

      it "must build correct XML with identical name and short name" do
        subject = AIXM::Factory.polygon_airspace(short_name: 'POLYGON AIRSPACE')
        subject.to_xml.wont_match(/txtLocalType/)
      end

      it "must build correct XML without schedule" do
        subject = AIXM::Factory.polygon_airspace(schedule: nil)
        subject.to_xml.wont_match(/codeWorkHr/)
      end
    end
  end
end
