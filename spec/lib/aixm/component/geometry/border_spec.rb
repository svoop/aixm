require_relative '../../../../spec_helper'

describe AIXM::Component::Geometry::Border do
  describe :to_xml do
    it "must build correct AIXM" do
      subject = AIXM.border(
        xy: AIXM.xy(lat: 11.1, long: 22.2),
        name: 'FRANCE-SWITZERLAND'
      )
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <Avx>
          <GbrUid>
            <txtName>FRANCE-SWITZERLAND</txtName>
          </GbrUid>
          <codeType>FNT</codeType>
          <geoLat>110600.00N</geoLat>
          <geoLong>0221200.00E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Avx>
      END
    end
  end
end
