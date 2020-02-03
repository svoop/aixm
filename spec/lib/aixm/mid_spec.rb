require_relative '../../spec_helper'

describe AIXM::Mid do
  subject do
    AIXM::Mid.new(xml: <<~END)
      <?xml version="1.0" encoding="UTF-8"?>
      <OFMX-Snapshot>
        <Ahp>
          <AhpUid region="EB">
            <codeId>EBAW</codeId>
          </AhpUid>
        </Ahp>
        <Rwy>
          <RwyUid>
            <AhpUid region="EB">
              <codeId>EBAW</codeId>
            </AhpUid>
            <txtDesig>11/29</txtDesig>
          </RwyUid>
        </Rwy>
      </OFMX-Snapshot>
    END
  end

  describe :xml_with_mid do
    it "calculates and inserts OFMX-compliant mid values" do
      _(subject.xml_with_mid).must_equal <<~END
        <?xml version="1.0" encoding="UTF-8"?>
        <OFMX-Snapshot>
          <Ahp>
            <AhpUid region="EB" mid="df97f099-d07d-04e6-adf8-e8294adaa0a3">
              <codeId>EBAW</codeId>
            </AhpUid>
          </Ahp>
          <Rwy>
            <RwyUid mid="ef163b2a-b50e-4b65-1315-ee77bcf865dc">
              <AhpUid region="EB" mid="df97f099-d07d-04e6-adf8-e8294adaa0a3">
                <codeId>EBAW</codeId>
              </AhpUid>
              <txtDesig>11/29</txtDesig>
            </RwyUid>
          </Rwy>
        </OFMX-Snapshot>
      END
    end
  end
end
