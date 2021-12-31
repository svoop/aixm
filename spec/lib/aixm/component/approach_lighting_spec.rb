require_relative '../../../spec_helper'

describe AIXM::Component::ApproachLighting do
  subject do
    AIXM::Factory.airport.runways.first.forth.approach_lightings.first
  end

  describe :type= do
    it "fails on invalid values" do
      _([:foobar, 123, nil]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { _1.type = :cat_1 }.type).must_equal :cat_1
      _(subject.tap { _1.type = :B }.type).must_equal :cat_2
    end
  end

  describe :length= do
    it "fails on invalid values" do
      _([:foobar, 0, 1]).wont_be_written_to subject, :length
    end

    it "accepts valid values" do
      _([nil, AIXM.d(1000, :m)]).must_be_written_to subject, :length
    end
  end

  describe :intensity= do
    macro :intensity
  end

  describe :sequenced_flash= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :sequenced_flash
    end

    it "accepts valid values" do
      _([true, false, nil]).must_be_written_to subject, :sequenced_flash
    end
  end

  describe :flash_description= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :flash_description
    end

    it "stringifies valid values" do
      _(subject.tap { _1.remarks = 'foobar' }.remarks).must_equal 'foobar'
      _(subject.tap { _1.remarks = 123 }.remarks).must_equal '123'
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml(as: :Rda)).must_equal <<~END
        <Rda>
          <RdaUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codeType>A</codeType>
          </RdaUid>
          <valLen>1000</valLen>
          <uomLen>M</uomLen>
          <codeIntst>LIH</codeIntst>
          <codeSequencedFlash>N</codeSequencedFlash>
          <txtDescrFlash>three grouped bursts</txtDescrFlash>
          <txtRmk>on demand</txtRmk>
        </Rda>
      END
    end
  end
end
