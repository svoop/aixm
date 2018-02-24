require_relative '../../../spec_helper'

describe AIXM::Component::VerticalLimits do
  describe :initialize do
    it "won't accept invalid arguments" do
      z = AIXM.z(1000, :qnh)
      -> { AIXM.vertical_limits(upper_z: 0, lower_z: z, max_z: z, min_z: z) }.must_raise ArgumentError
      -> { AIXM.vertical_limits(upper_z: z, lower_z: 0, max_z: z, min_z: z) }.must_raise ArgumentError
      -> { AIXM.vertical_limits(upper_z: z, lower_z: z, max_z: 0, min_z: z) }.must_raise ArgumentError
      -> { AIXM.vertical_limits(upper_z: z, lower_z: z, max_z: z, min_z: 0) }.must_raise ArgumentError
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = AIXM.vertical_limits(
        upper_z: AIXM.z(2000, :qnh),
        lower_z: AIXM::GROUND
      )
      subject.to_digest.must_equal 867600845
    end
  end

  describe :to_aixm do
    it "must build correct AIXM with only upper_z and lower_z" do
      subject = AIXM.vertical_limits(
        upper_z: AIXM.z(2000, :qnh),
        lower_z: AIXM::GROUND
      )
      AIXM.aixm!
      subject.to_xml.must_equal <<~END
        <codeDistVerUpper>ALT</codeDistVerUpper>
        <valDistVerUpper>2000</valDistVerUpper>
        <uomDistVerUpper>FT</uomDistVerUpper>
        <codeDistVerLower>HEI</codeDistVerLower>
        <valDistVerLower>0</valDistVerLower>
        <uomDistVerLower>FT</uomDistVerLower>
      END
    end

    it "must build correct AIXM with additional max_z" do
      subject = AIXM.vertical_limits(
        upper_z: AIXM.z(65, :qne),
        lower_z: AIXM.z(1000, :qfe),
        max_z: AIXM.z(6000, :qnh)
      )
      AIXM.aixm!
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

    it "must build correct AIXM with additional min_z" do
      subject = AIXM.vertical_limits(
        upper_z: AIXM.z(65, :qne),
        lower_z: AIXM.z(45, :qne),
        min_z: AIXM.z(3000, :qnh)
      )
      AIXM.aixm!
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
