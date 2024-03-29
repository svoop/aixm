require_relative '../../../spec_helper'

describe AIXM::Component::Geometry do
  context "singularity" do
    subject do
      AIXM.geometry
    end

    it "must fail checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).wont_be :polygon?
      _(subject).wont_be :closed?
    end

    it "must fail to build AIXM" do
      _{ subject.to_xml }.must_raise AIXM::GeometryError
    end
  end

  context "point" do
    subject do
      AIXM.geometry(
        AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      )
    end

    it "must pass checks" do
      _(subject).must_be :point?
      _(subject).wont_be :circle?
      _(subject).wont_be :polygon?
      _(subject).must_be :closed?
    end

    it "must return elements" do
      _(subject.segments.count).must_equal 1
    end

    it "builds valid AIXM" do
      _(subject.to_xml).must_equal <<~END
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>110000.00N</geoLat>
          <geoLong>0220000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end

  context "great circle line" do
    subject do
      AIXM.geometry(
        AIXM.point(xy: AIXM.xy(lat: 11, long: 22)),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      )
    end

    it "must fail checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).wont_be :polygon?
      _(subject).wont_be :closed?
    end

    it "must fail to build AIXM" do
      _{ subject.to_xml }.must_raise AIXM::GeometryError
    end
  end

  context "closed polygon" do
    subject do
      AIXM.geometry(
        AIXM.point(xy: AIXM.xy(lat: 11, long: 22)),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33)),
        AIXM.point(xy: AIXM.xy(lat: 33, long: 44)),
        AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      )
    end

    it "must pass checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).must_be :polygon?
      _(subject).must_be :closed?
    end

    it "must return elements" do
      _(subject.segments.count).must_equal 4
    end

    it "builds valid AIXM" do
      _(subject.to_xml).must_equal <<~END
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
      END
    end
  end

  context "unclosed polygon" do
    subject do
      AIXM.geometry(
        AIXM.point(xy: AIXM.xy(lat: 11, long: 22)),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33)),
        AIXM.point(xy: AIXM.xy(lat: 33, long: 44))
      )
    end

    it "must fail checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).wont_be :polygon?
      _(subject).wont_be :closed?
    end

    it "must fail to build AIXM" do
      _{ subject.to_xml }.must_raise AIXM::GeometryError
    end
  end

  context "closed arc" do
    subject do
      AIXM.geometry(
        AIXM.arc(xy: AIXM.xy(lat: 11, long: 22), center_xy: AIXM.xy(lat: 10, long: 20), clockwise: true),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33)),
        AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      )
    end

    it "must pass checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).must_be :polygon?
      _(subject).must_be :closed?
    end

    it "builds valid AIXM" do
      _(subject.to_xml).must_equal <<~END
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
        <Avx>
          <codeType>GRC</codeType>
          <geoLat>110000.00N</geoLat>
          <geoLong>0220000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end

  context "unclosed arc" do
    subject do
      AIXM.geometry(
        AIXM.arc(xy: AIXM.xy(lat: 11, long: 22), center_xy: AIXM.xy(lat: 10, long: 20), clockwise: true),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      )
    end

    it "must fail checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).wont_be :polygon?
      _(subject).wont_be :closed?
    end

    it "must fail to build AIXM" do
      _{ subject.to_xml }.must_raise AIXM::GeometryError
    end
  end

  context "closed border" do
    subject do
      AIXM.geometry(
        AIXM.border(xy: AIXM.xy(lat: 11, long: 22), name: 'foobar'),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33)),
        AIXM.point(xy: AIXM.xy(lat: 11, long: 22))
      )
    end

    it "must pass checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).must_be :polygon?
      _(subject).must_be :closed?
    end

    it "builds valid AIXM" do
      _(subject.to_xml).must_equal <<~END
        <Avx>
          <GbrUid>
            <txtName>foobar</txtName>
          </GbrUid>
          <codeType>FNT</codeType>
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
          <geoLat>110000.00N</geoLat>
          <geoLong>0220000.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end

  context "unclosed border" do
    subject do
      AIXM.geometry(
        AIXM.border(xy: AIXM.xy(lat: 11, long: 22), name: 'foobar'),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      )
    end

    it "must fail checks" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).wont_be :polygon?
      _(subject).wont_be :closed?
    end

    it "must fail to build AIXM" do
      _{ subject.to_xml }.must_raise AIXM::GeometryError
    end
  end

  context "circle" do
    subject do
      AIXM.geometry(
        AIXM.circle(center_xy: AIXM.xy(lat: 11, long: 22), radius: AIXM.d(10, :km))
      )
    end

    it "must pass checks" do
      _(subject).wont_be :point?
      _(subject).must_be :circle?
      _(subject).wont_be :polygon?
      _(subject).must_be :closed?
    end

    it "builds valid AIXM" do
      _(subject.to_xml).must_equal <<~END
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
  end

  context "circle with additional elements" do
    subject do
      AIXM.geometry(
        AIXM.circle(center_xy: AIXM.xy(lat: 11, long: 22), radius: AIXM.d(10, :km)),
        AIXM.point(xy: AIXM.xy(lat: 22, long: 33))
      )
    end

    it "must fail checks when additional elements are present" do
      _(subject).wont_be :point?
      _(subject).wont_be :circle?
      _(subject).wont_be :polygon?
      _(subject).wont_be :closed?
    end

    it "must fail to build AIXM" do
      _{ subject.to_xml }.must_raise AIXM::GeometryError
    end
  end

end
