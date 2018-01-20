require_relative '../../../spec_helper'

describe AIXM::Horizontal::Border do
  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM::Horizontal::Border.new(
        xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        name: 'foobar'
      )
      subject.to_digest.must_equal 813052011
    end
  end

  describe :to_xml do
    it "must build correct XML" do
      subject = AIXM::Horizontal::Border.new(
        xy: AIXM::XY.new(lat: 11.1, long: 22.2),
        name: 'foobar'
      )
      subject.to_xml.must_equal <<~END
      <Avx>
        <codeType>FNT</codeType>
        <geoLat>110600.00N</geoLat>
        <geoLong>0221200.00E</geoLong>
        <codeDatum>WGE</codeDatum>
      </Avx>
      END
    end
  end
end
