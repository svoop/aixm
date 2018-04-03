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
        -> { subject.class = 'X' }.must_raise ArgumentError
      end

      it "symbolizes and upcases value" do
        subject.tap { |s| s.class = 'c' }.class.must_equal :C
      end
    end

    describe :vertical_limits= do
      it "fails on invalid values" do
        -> { subject.vertical_limits = 'foobar' }.must_raise ArgumentError
      end
    end

    describe :schedule= do
      macro :schedule
    end

    describe :selective= do
      it "fails on invalid values" do
        -> { subject.selective = 'N' }.must_raise ArgumentError
      end
    end

    describe :remarks= do
      macro :remarks
    end

    describe :to_xml do
      it "must build correct OFMX" do
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

      it "must build correct AIXM" do
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

    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <codeClass>C</codeClass>
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

    it "must build correct AIXM" do
      AIXM.aixm!
      subject.to_xml.wont_match(/<codeSelAvbl>/)
    end
  end

end
