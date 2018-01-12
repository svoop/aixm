require_relative '../../../spec_helper'

describe AIXM::Horizontal::Border do
  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM::Horizontal::Border.new(
        xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        name: 'foobar',
        name_mid: 123
      )
      subject.to_digest.must_equal '8955450f'
    end
  end

  describe :to_xml do
    it "must build correct XML with name_mid" do
      subject = AIXM::Horizontal::Border.new(
        xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        name: 'foobar',
        name_mid: 123
      )
      subject.to_xml.must_equal "<Avx><codeType>FNT</codeType><geoLat>11.10000000N</geoLat><geoLong>22.20000000E</geoLong><GbrUid mid=\"123\"><txtName>foobar</txtName></GbrUid></Avx>"
    end

    it "must build correct XML without name_mid" do
      subject = AIXM::Horizontal::Border.new(
        xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        name: 'foobar'
      )
      subject.to_xml.must_equal "<Avx><codeType>FNT</codeType><geoLat>11.10000000N</geoLat><geoLong>22.20000000E</geoLong><GbrUid><txtName>foobar</txtName></GbrUid></Avx>"
    end
  end
end
