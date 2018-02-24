require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::Marker do
  context "complete outer marker" do
    subject do
      AIXM::Factory.marker
    end

    let :digest do
      subject.to_digest
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "Marker:O"
      end
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 300437209
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <!-- NavigationalAid: [Marker:O] MARKER NAVAID -->
          <Mkr>
            <MkrUid mid="#{digest}" newEntity="true">
              <codeId>---</codeId>
              <geoLat>47.85916667N</geoLat>
              <geoLong>7.56000000E</geoLong>
            </MkrUid>
            <OrgUid/>
            <codePsnIls>O</codePsnIls>
            <valFreq>75</valFreq>
            <uomFreq>MHZ</uomFreq>
            <txtName>MARKER NAVAID</txtName>
            <codeDatum>WGE</codeDatum>
            <valElev>500</valElev>
            <uomDistVer>FT</uomDistVer>
            <Mtt>
              <codeWorkHr>H24</codeWorkHr>
            </Mtt>
            <txtRmk>marker navaid</txtRmk>
          </Mkr>
        END
      end
    end
  end

  context "complete middle marker" do
    subject do
      AIXM::Factory.marker.tap do |marker|
        marker.type = :middle
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "Marker:M"
      end
    end

    describe :to_xml do
      it "must build correct XML" do
        subject.to_xml.must_match %r(<codePsnIls>M</codePsnIls>)
      end
    end
  end
  context "complete middle marker" do
    subject do
      AIXM::Factory.marker.tap do |marker|
        marker.type = :middle
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "Marker:M"
      end
    end

    describe :to_xml do
      it "must build correct XML" do
        subject.to_xml.must_match %r(<codePsnIls>M</codePsnIls>)
      end
    end
  end

  context "complete inner marker" do
    subject do
      AIXM::Factory.marker.tap do |marker|
        marker.type = :inner
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "Marker:I"
      end
    end

    describe :to_xml do
      it "must build correct XML" do
        subject.to_xml.must_match %r(<codePsnIls>I</codePsnIls>)
      end
    end
  end

  context "complete backcourse marker" do
    subject do
      AIXM::Factory.marker.tap do |marker|
        marker.type = :backcourse
      end
    end

    describe :kind do
      it "must return class/type combo" do
        subject.kind.must_equal "Marker:C"
      end
    end

    describe :to_xml do
      it "must build correct XML" do
        subject.to_xml.must_match %r(<codePsnIls>C</codePsnIls>)
      end
    end
  end
end
