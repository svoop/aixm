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
    it "populates the mid attribute" do
      _(subject.mid).must_be :nil?
      subject.to_xml(as: :Rls)
      _(subject.mid).wont_be :nil?
    end

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

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid = true
      AIXM.config.region = 'LF'
      _(subject.to_xml(as: :Rls)).must_match /<RlsUid [^>]*? mid="29500769-112c-2480-6e88-5dbfc4976608"/x
    end
  end
end
