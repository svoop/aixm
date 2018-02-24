require_relative '../../../spec_helper'

describe AIXM::Component::Geometry do
  context "singularity" do
    subject do
      AIXM.geometry
    end

    it "must fail validation" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :complete?
    end
  end

  context "point" do
    subject do
      AIXM.geometry.tap do |geometry|
        geometry << AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      end
    end

    it "must fail validation" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :complete?
    end
  end

  context "line" do
    subject do
      AIXM.geometry.tap do |geometry|
        geometry << AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
        geometry << AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      end
    end

    it "must fail validation" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :complete?
    end
  end

  context "polygon" do
    subject do
      AIXM.geometry.tap do |geometry|
        geometry << AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
        geometry << AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      end
    end

    it "must recognize unclosed" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :complete?
    end

    it "must recognize closed" do
      subject << AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.must_be :closed_shape?
      subject.must_be :complete?
    end

    it "must return elements" do
      subject.segments.count.must_equal 2
    end

    it "must return digest of payload" do
      subject.to_digest.must_equal 310635400
    end

    it "must build valid AIXM" do
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
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
      END
    end
  end

  context "arc" do
    subject do
      AIXM.geometry.tap do |geometry|
        geometry << AIXM.arc(xy: AIXM.xy(lat: 11, long: 22), center_xy: AIXM.xy(lat: 10, long: 20), clockwise: true)
        geometry << AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      end
    end

    it "must recognize unclosed" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :complete?
    end

    it "must recognize closed" do
      subject << AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.must_be :closed_shape?
      subject.must_be :complete?
    end

    it "must build valid AIXM" do
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>110000.00N</geoLat>
          <geoLong>0220000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
          <geoLatArc>100000.00N</geoLatArc>
          <geoLongArc>0200000.00E</geoLongArc>
        </Avx>
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>220000.00N</geoLat>
          <geoLong>0330000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end

    it "must return digest of payload" do
      subject.to_digest.must_equal 368159360
    end
  end

  context "border" do
    subject do
      AIXM.geometry.tap do |geometry|
        geometry << AIXM.border(xy: AIXM.xy(lat: 11, long: 22), name: 'foobar')
        geometry << AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      end
    end

    it "must recognize unclosed" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :complete?
    end

    it "must recognize closed" do
      subject << AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.must_be :closed_shape?
      subject.must_be :complete?
    end

    it "must build valid AIXM" do
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>FNT</codeType>
          <geoLat>110000.00N</geoLat>
          <geoLong>0220000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
          <GbrUid>
            <txtName>foobar</txtName>
          </GbrUid>
        </Avx>
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>220000.00N</geoLat>
          <geoLong>0330000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end

    it "must return digest of payload" do
      subject.to_digest.must_equal 204277421
    end
  end

  context "circle" do
    subject do
      AIXM.geometry.tap do |geometry|
        geometry << AIXM.circle(center_xy: AIXM.xy(lat: 11, long: 22), radius: 10)
      end
    end

    it "must pass validation" do
      subject.must_be :circle?
      subject.wont_be :closed_shape?
      subject.must_be :complete?
    end

    it "must fail validation when additional elements are present" do
      subject << AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :complete?
    end

    it "must build valid AIXM" do
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>110523.76N</geoLat>
          <geoLong>0220000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
          <geoLatArc>110000.00N</geoLatArc>
          <geoLongArc>0220000.00E</geoLongArc>
        </Avx>
      END
    end

    it "must return digest of payload" do
      subject.to_digest.must_equal 470722036
    end
  end
end
