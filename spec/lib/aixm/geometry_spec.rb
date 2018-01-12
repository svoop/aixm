require_relative '../../spec_helper'

describe AIXM::Geometry do
  context "singularity" do
    subject do
      AIXM::Geometry.new
    end

    it "must fail validation" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :valid?
    end
  end

  context "point" do
    subject do
      AIXM::Geometry.new.tap do |geometry|
        geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
      end
    end

    it "must fail validation" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :valid?
    end
  end

  context "line" do
    subject do
      AIXM::Geometry.new.tap do |geometry|
        geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
        geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 22, long: 33))
      end
    end

    it "must fail validation" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :valid?
    end
  end

  context "polygon" do
    subject do
      AIXM::Geometry.new.tap do |geometry|
        geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
        geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 22, long: 33))
      end
    end

    it "must recognize unclosed" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :valid?
    end

    it "must recognize closed" do
      subject << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.must_be :closed_shape?
      subject.must_be :valid?
    end

    it "must build valid XML" do
      subject.to_xml.must_equal '<Avx><codeType>GRC</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong></Avx><Avx><codeType>GRC</codeType><geoLat>22.00000000N</geoLat><geoLong>33.00000000E</geoLong></Avx>'
    end
  end

  context "arc" do
    subject do
      AIXM::Geometry.new.tap do |geometry|
        geometry << AIXM::Horizontal::Arc.new(xy: AIXM::XY.new(lat: 11, long: 22), center_xy: AIXM::XY.new(lat: 10, long: 20), clockwise: true)
        geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 22, long: 33))
      end
    end

    it "must recognize unclosed" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :valid?
    end

    it "must recognize closed" do
      subject << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.must_be :closed_shape?
      subject.must_be :valid?
    end

    it "must build valid XML" do
      subject.to_xml.must_equal '<Avx><codeType>CWA</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong><geoLatArc>10.00000000N</geoLatArc><geoLongArc>20.00000000E</geoLongArc></Avx><Avx><codeType>GRC</codeType><geoLat>22.00000000N</geoLat><geoLong>33.00000000E</geoLong></Avx>'
    end
  end

  context "border" do
    subject do
      AIXM::Geometry.new.tap do |geometry|
        geometry << AIXM::Horizontal::Border.new(xy: AIXM::XY.new(lat: 11, long: 22), name: 'foobar')
        geometry << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 22, long: 33))
      end
    end

    it "must recognize unclosed" do
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :valid?
    end

    it "must recognize closed" do
      subject << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.must_be :closed_shape?
      subject.must_be :valid?
    end

    it "must build valid XML" do
      subject.to_xml.must_equal '<Avx><codeType>FNT</codeType><geoLat>11.00000000N</geoLat><geoLong>22.00000000E</geoLong><GbrUid><txtName>foobar</txtName></GbrUid></Avx><Avx><codeType>GRC</codeType><geoLat>22.00000000N</geoLat><geoLong>33.00000000E</geoLong></Avx>'
    end
  end

  context "circle" do
    subject do
      AIXM::Geometry.new.tap do |geometry|
        geometry << AIXM::Horizontal::Circle.new(center_xy: AIXM::XY.new(lat: 11, long: 22), radius: 10)
      end
    end

    it "must pass validation" do
      subject.must_be :circle?
      subject.wont_be :closed_shape?
      subject.must_be :valid?
    end

    it "must fail validation when additional elements are present" do
      subject << AIXM::Horizontal::Point.new(xy: AIXM::XY.new(lat: 11, long: 22))
      subject.wont_be :circle?
      subject.wont_be :closed_shape?
      subject.wont_be :valid?
    end

    it "must build valid XML" do
      subject.to_xml.must_equal '<Avx><codeType>CWA</codeType><geoLat>11.08993216N</geoLat><geoLong>22.00000000E</geoLong><geoLatArc>11.00000000N</geoLatArc><geoLongArc>22.00000000E</geoLongArc></Avx>'
    end
  end

end
