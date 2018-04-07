require_relative '../../../spec_helper'

describe AIXM::Component::VerticalLimits do
  subject do
    AIXM::Factory.vertical_limits
  end

  describe :upper_z= do
    it "fails on invalid values" do
      -> { subject.upper_z = :foobar }.must_raise ArgumentError
      -> { subject.upper_z = nil }.must_raise ArgumentError
    end
  end

  describe :lower_z= do
    it "fails on invalid values" do
      -> { subject.lower_z = :foobar }.must_raise ArgumentError
      -> { subject.lower_z = nil }.must_raise ArgumentError
    end
  end

  describe :max_z= do
    it "fails on invalid values" do
      -> { subject.max_z = :foobar }.must_raise ArgumentError
    end

    it "accepts nil values" do
      subject.tap { |s| s.max_z = nil }.max_z.must_be :nil?
    end
  end

  describe :min_z= do
    it "fails on invalid values" do
      -> { subject.min_z = :foobar }.must_raise ArgumentError
    end

    it "accepts nil values" do
      subject.tap { |s| s.min_z = nil }.min_z.must_be :nil?
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
