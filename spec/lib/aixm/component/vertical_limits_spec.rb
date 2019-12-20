require_relative '../../../spec_helper'

describe AIXM::Component::VerticalLimit do
  subject do
    AIXM::Factory.vertical_limit
  end

  describe :upper_z= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :upper_z
    end
  end

  describe :max_z= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :max_z
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :max_z
    end
  end

  describe :lower_z= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :lower_z
    end
  end

  describe :min_z= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :min_z
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :max_z
    end
  end

  describe :to_aixm do
    it "builds correct AIXM with only upper_z and lower_z" do
      subject = AIXM.vertical_limit(
        upper_z: AIXM.z(2000, :qnh),
        lower_z: AIXM::GROUND
      )
      _(subject.to_xml).must_equal <<~END
        <codeDistVerUpper>ALT</codeDistVerUpper>
        <valDistVerUpper>2000</valDistVerUpper>
        <uomDistVerUpper>FT</uomDistVerUpper>
        <codeDistVerLower>HEI</codeDistVerLower>
        <valDistVerLower>0</valDistVerLower>
        <uomDistVerLower>FT</uomDistVerLower>
      END
    end

    it "builds correct AIXM with additional max_z" do
      subject = AIXM.vertical_limit(
        upper_z: AIXM.z(65, :qne),
        max_z: AIXM.z(6000, :qnh),
        lower_z: AIXM.z(1000, :qfe)
      )
      _(subject.to_xml).must_equal <<~END
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

    it "builds correct AIXM with additional min_z" do
      subject = AIXM.vertical_limit(
        upper_z: AIXM.z(65, :qne),
        lower_z: AIXM.z(45, :qne),
        min_z: AIXM.z(3000, :qnh)
      )
      _(subject.to_xml).must_equal <<~END
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
