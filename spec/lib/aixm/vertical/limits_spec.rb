require_relative '../../../spec_helper'

describe AIXM::Vertical::Limits do
  describe :initialize do
    it "won't accept invalid arguments" do
      z = AIXM::Z.new(alt: 1000, code: :QNH)
      -> { AIXM::Vertical::Limits.new(upper_z: 0, lower_z: z, max_z: z, min_z: z) }.must_raise ArgumentError
      -> { AIXM::Vertical::Limits.new(upper_z: z, lower_z: 0, max_z: z, min_z: z) }.must_raise ArgumentError
      -> { AIXM::Vertical::Limits.new(upper_z: z, lower_z: z, max_z: 0, min_z: z) }.must_raise ArgumentError
      -> { AIXM::Vertical::Limits.new(upper_z: z, lower_z: z, max_z: z, min_z: 0) }.must_raise ArgumentError
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM::Vertical::Limits.new(
        upper_z: AIXM::Z.new(alt: 2000, code: :QNH),
        lower_z: AIXM::GROUND
      )
      subject.to_digest.must_equal 929399130
    end
  end

  describe :to_xml do
    it "must build correct XML with only upper_z and lower_z" do
      subject = AIXM::Vertical::Limits.new(
        upper_z: AIXM::Z.new(alt: 2000, code: :QNH),
        lower_z: AIXM::GROUND
      )
      subject.to_xml.must_equal <<~END
        <codeDistVerUpper>ALT</codeDistVerUpper>
        <valDistVerUpper>2000</valDistVerUpper>
        <uomDistVerUpper>FT</uomDistVerUpper>
        <codeDistVerLower>HEI</codeDistVerLower>
        <valDistVerLower>0</valDistVerLower>
        <uomDistVerLower>FT</uomDistVerLower>
      END
    end

    it "must build correct XML with additional max_z" do
      subject = AIXM::Vertical::Limits.new(
        upper_z: AIXM::Z.new(alt: 65, code: :QNE),
        lower_z: AIXM::Z.new(alt: 1000, code: :QFE),
        max_z: AIXM::Z.new(alt: 6000, code: :QNH)
      )
      subject.to_xml.must_equal <<~END
        <codeDistVerUpper>STD</codeDistVerUpper>
        <valDistVerUpper>65</valDistVerUpper>
        <uomDistVerUpper>FL</uomDistVerUpper>
        <codeDistVerLower>HEI</codeDistVerLower>
        <valDistVerLower>1000</valDistVerLower>
        <uomDistVerLower>FT</uomDistVerLower>
        <codeDistVerMax>ALT</codeDistVerMax>
        <valDistVerMax>6000</valDistVerMax>
        <uomDistVerMax>FT</uomDistVerMax>
      END
    end

    it "must build correct XML with additional min_z" do
      subject = AIXM::Vertical::Limits.new(
        upper_z: AIXM::Z.new(alt: 65, code: :QNE),
        lower_z: AIXM::Z.new(alt: 45, code: :QNE),
        min_z: AIXM::Z.new(alt: 3000, code: :QNH)
      )
      subject.to_xml.must_equal <<~END
        <codeDistVerUpper>STD</codeDistVerUpper>
        <valDistVerUpper>65</valDistVerUpper>
        <uomDistVerUpper>FL</uomDistVerUpper>
        <codeDistVerLower>STD</codeDistVerLower>
        <valDistVerLower>45</valDistVerLower>
        <uomDistVerLower>FL</uomDistVerLower>
        <codeDistVerMnm>ALT</codeDistVerMnm>
        <valDistVerMnm>3000</valDistVerMnm>
        <uomDistVerMnm>FT</uomDistVerMnm>
      END
    end
  end
end
