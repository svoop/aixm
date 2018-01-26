require_relative '../../../spec_helper'

describe AIXM::Component::ClassLayer do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM.class_layer(class: 'X', vertical_limits: AIXM::Factory.vertical_limits ) }.must_raise ArgumentError
      -> { AIXM.class_layer(class: 'A', vertical_limits: 'foobar') }.must_raise ArgumentError
    end
  end

  context "with class" do
    subject do
      AIXM.class_layer(class: :C, vertical_limits: AIXM::Factory.vertical_limits)
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 385936206
      end
    end

    describe :to_aixm do
      it "must build correct XML" do
        subject.to_aixm.must_equal <<~END
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
      AIXM.class_layer(vertical_limits: AIXM::Factory.vertical_limits)
    end

    describe :to_digest do
      it "must return digest of payload" do
        subject.to_digest.must_equal 5930767
      end
    end

    describe :to_aixm do
      it "must build correct XML" do
        subject.to_aixm.must_equal <<~END
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
