require_relative '../../../spec_helper'

describe AIXM::Horizontal::Border do
  describe :to_xml do
    it "must build correct XML with mid" do
      subject = AIXM::Horizontal::Border.new(
        xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        name: 'foobar',
        mid: 123
      )
      subject.to_xml.must_equal "<Avx><codeType>FNT</codeType><geoLat>11.10000000N</geoLat><geoLong>22.20000000E</geoLong><GbrUid mid=\"123\"><txtName>foobar</txtName></GbrUid></Avx>"
    end
  end

  describe :to_xml do
    it "must build correct XML without mid" do
      subject = AIXM::Horizontal::Border.new(
        xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        name: 'foobar'
      )
      subject.to_xml.must_equal "<Avx><codeType>FNT</codeType><geoLat>11.10000000N</geoLat><geoLong>22.20000000E</geoLong><GbrUid><txtName>foobar</txtName></GbrUid></Avx>"
    end
  end
end
