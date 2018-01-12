require_relative '../../../spec_helper'

describe AIXM::Horizontal::Arc do
  describe :initialize do
    it "won't accept invalid arguments" do
      xy = AIXM::XY.new(lat: 11.1, long: 22.2)
      -> { AIXM::Horizontal::Arc.new(xy: 0, center_xy: xy, clockwise: true) }.must_raise ArgumentError
      -> { AIXM::Horizontal::Arc.new(xy: xy, center_xy: 0, clockwise: true) }.must_raise ArgumentError
      -> { AIXM::Horizontal::Arc.new(xy: xy, center_xy: xy, clockwise: 0) }.must_raise ArgumentError
    end
  end

  describe :clockwise? do
    it "must return true or false" do
      xy = AIXM::XY.new(lat: 11.1, long: 22.2)
      AIXM::Horizontal::Arc.new(xy: xy, center_xy: xy, clockwise: true).must_be :clockwise?
      AIXM::Horizontal::Arc.new(xy: xy, center_xy: xy, clockwise: false).wont_be :clockwise?
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM::Horizontal::Arc.new(
        xy: AIXM::XY.new(lat: 11.1, long: 33.3),
        center_xy: AIXM::XY.new(lat: 22.2, long: 33.3),
        clockwise: true
      )
      subject.to_digest.must_equal '35b2e1af'
    end
  end

  describe :to_xml do
    it "must build correct XML for clockwise arcs" do
      subject = AIXM::Horizontal::Arc.new(
        xy: AIXM::XY.new(lat: 11.1, long: 33.3),
        center_xy: AIXM::XY.new(lat: 22.2, long: 33.3),
        clockwise: true
      )
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CWA</codeType>
          <geoLat>11.10000000N</geoLat>
          <geoLong>33.30000000E</geoLong>
          <geoLatArc>22.20000000N</geoLatArc>
          <geoLongArc>33.30000000E</geoLongArc>
        </Avx>
      END
    end

    it "must build correct XML for counter-clockwise arcs" do
      subject = AIXM::Horizontal::Arc.new(
        xy: AIXM::XY.new(lat: 11.1, long: 33.3),
        center_xy: AIXM::XY.new(lat: 22.2, long: 33.3),
        clockwise: false
      )
      subject.to_xml.must_equal <<~END
        <Avx>
          <codeType>CCA</codeType>
          <geoLat>11.10000000N</geoLat>
          <geoLong>33.30000000E</geoLong>
          <geoLatArc>22.20000000N</geoLatArc>
          <geoLongArc>33.30000000E</geoLongArc>
        </Avx>
      END
    end
  end
end
