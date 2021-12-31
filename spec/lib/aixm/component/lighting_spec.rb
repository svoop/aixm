require_relative '../../../spec_helper'

describe AIXM::Component::Lighting do
  subject do
    AIXM::Factory.airport.runways.first.forth.lightings.first
  end

  describe :position= do
    it "fails on invalid values" do
      _([:foobar, 123, nil]).wont_be_written_to subject, :position
    end

    it "looks up valid values" do
      _(subject.tap { _1.position = :edge }.position).must_equal :edge
      _(subject.tap { _1.position = :SWYEND }.position).must_equal :stopway_end
    end
  end

  describe :description= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :description
    end

    it "stringifies valid values" do
      _(subject.tap { _1.description = 'foobar' }.description).must_equal 'foobar'
      _(subject.tap { _1.description = 123 }.description).must_equal '123'
    end
  end

  describe :intensity= do
    macro :intensity
  end

  describe :color= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :color
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :color
    end

    it "looks up valid values" do
      _(subject.tap { _1.color = :blue }.color).must_equal :blue
      _(subject.tap { _1.color = 'GRN' }.color).must_equal :green
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml(as: :Rls)).must_equal <<~END
        <Rls>
          <RlsUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codePsn>AIM</codePsn>
          </RlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Rls>
      END
    end
  end
end
