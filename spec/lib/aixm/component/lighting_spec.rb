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
      _(subject.tap { |s| s.position = :edge }.position).must_equal :edge
      _(subject.tap { |s| s.position = :SWYEND }.position).must_equal :stopway_end
    end
  end

  describe :description= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :description
    end

    it "stringifies valid values" do
      _(subject.tap { |s| s.description = 'foobar' }.description).must_equal 'foobar'
      _(subject.tap { |s| s.description = 123 }.description).must_equal '123'
    end
  end

  describe :intensity= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :intensity
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :intensity
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.intensity = :low }.intensity).must_equal :low
      _(subject.tap { |s| s.intensity = 'LIM' }.intensity).must_equal :medium
    end
  end

  describe :color= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :color
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :color
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.color = :blue }.color).must_equal :blue
      _(subject.tap { |s| s.color = 'GRN' }.color).must_equal :green
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct complete AIXM/OFMX" do
      _(subject.to_xml(as: :Rls)).must_equal <<~END
        <Rls>
          <RlsUid>
            <RdnUid>
              <RwyUid>
                <AhpUid>
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
