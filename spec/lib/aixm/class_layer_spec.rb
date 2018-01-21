require_relative '../../spec_helper'

describe AIXM::ClassLayer do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM::ClassLayer.new(class: 'X', vertical_limits: AIXM::Factory.vertical_limits ) }.must_raise ArgumentError
      -> { AIXM::ClassLayer.new(class: 'A', vertical_limits: 'foobar') }.must_raise ArgumentError
    end
  end

  context "with class" do
    subject do
      AIXM::ClassLayer.new(class: :C, vertical_limits: AIXM::Factory.vertical_limits)
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 612555203
      end
    end

    describe :to_xml do
      it "must build correct XML" do
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
        END
      end
    end
  end

  context "without class" do
    subject do
      AIXM::ClassLayer.new(vertical_limits: AIXM::Factory.vertical_limits)
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 486148039
      end
    end

    describe :to_xml do
      it "must build correct XML" do
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
        END
      end
    end
  end

end
