require_relative '../../../spec_helper'

describe AIXM::Component::Layer do

  context "only required attributes set" do
    subject do
      AIXM.layer(vertical_limits: AIXM::Factory.vertical_limits)
    end

    describe :initialize do
      it "sets defaults" do
        subject.wont_be :selective?
      end
    end

    describe :class= do
      it "fails on invalid values" do
        [:X, 'X'].wont_be_written_to subject, :class
      end

      it "symbolizes and upcases valid values" do
        subject.tap { |s| s.class = 'c' }.class.must_equal :C
      end
    end

    describe :vertical_limits= do
      it "fails on invalid values" do
        [nil, :foobar, 123].wont_be_written_to subject, :vertical_limits
      end
    end

    describe :activity= do
      it "fails on invalid values" do
        [:foobar, 123].wont_be_written_to subject, :activity
      end

      it "looks up valid values" do
        subject.tap { |s| s.activity = :aerodrome_traffic }.activity.must_equal :aerodrome_traffic
        subject.tap { |s| s.activity = :GLIDER }.activity.must_equal :gliding
      end
    end

    describe :timetable= do
      macro :timetable
    end

    describe :selective= do
      it "fails on invalid values" do
        [nil, 'N', 0].wont_be_written_to subject, :selective
      end
    end

    describe :remarks= do
      macro :remarks
    end

    describe :to_xml do
      it "builds correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~END
          <codeDistVerUpper>STD</codeDistVerUpper>
          <valDistVerUpper>65</valDistVerUpper>
          <uomDistVerUpper>FL</uomDistVerUpper>
          <codeDistVerLower>STD</codeDistVerLower>
          <valDistVerLower>45</valDistVerLower>
          <uomDistVerLower>FL</uomDistVerLower>
          <codeDistVerMax>ALT</codeDistVerMax>
          <valDistVerMax>6000</valDistVerMax>
          <uomDistVerMax>FT</uomDistVerMax>
          <codeDistVerMnm>HEI</codeDistVerMnm>
          <valDistVerMnm>3000</valDistVerMnm>
          <uomDistVerMnm>FT</uomDistVerMnm>
          <codeSelAvbl>N</codeSelAvbl>
        END
      end

      it "builds correct AIXM" do
        AIXM.aixm!
        subject.to_xml.wont_match(/<codeSelAvbl>/)
        subject.to_xml.wont_match(/<Att>/)
        subject.to_xml.wont_match(/<txtRmk>/)
      end
    end
  end

  context "required and optional attributes set" do
    subject do
      AIXM::Factory.layer
    end

    it "builds correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <codeClass>C</codeClass>
        <codeActivity>TFC-AD</codeActivity>
        <codeDistVerUpper>STD</codeDistVerUpper>
        <valDistVerUpper>65</valDistVerUpper>
        <uomDistVerUpper>FL</uomDistVerUpper>
        <codeDistVerLower>STD</codeDistVerLower>
        <valDistVerLower>45</valDistVerLower>
        <uomDistVerLower>FL</uomDistVerLower>
        <codeDistVerMax>ALT</codeDistVerMax>
        <valDistVerMax>6000</valDistVerMax>
        <uomDistVerMax>FT</uomDistVerMax>
        <codeDistVerMnm>HEI</codeDistVerMnm>
        <valDistVerMnm>3000</valDistVerMnm>
        <uomDistVerMnm>FT</uomDistVerMnm>
        <Att>
          <codeWorkHr>H24</codeWorkHr>
        </Att>
        <codeSelAvbl>Y</codeSelAvbl>
        <txtRmk>airspace layer</txtRmk>
      END
    end

    it "builds correct AIXM" do
      AIXM.aixm!
      subject.to_xml.wont_match(/<codeSelAvbl>/)
    end
  end

end
