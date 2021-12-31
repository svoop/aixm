require_relative '../../../spec_helper'

describe AIXM::Component::VASIS do
  subject do
    AIXM::Factory.airport.runways.first.forth.vasis
  end

  describe :type= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :type
    end

    it "accepts nil values" do
      _([nil]).must_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { _1.type = :t_shaped_vasis }.type).must_equal :t_shaped_vasis
      _(subject.tap { _1.type = :HAPI }.type).must_equal :helicopter_api
    end
  end

  describe :position= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :position
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :position
    end

    it "looks up valid values" do
      _(subject.tap { _1.position = :right }.position).must_equal :right
      _(subject.tap { _1.position = 'BOTH' }.position).must_equal :left_and_right
    end
  end

  describe :boxes_count= do
    it "fails on invalid values" do
      _([:foobar, -5, 0]).wont_be_written_to subject, :boxes_count
    end

    it "accepts valid values" do
      _([nil, 1, 5]).must_be_written_to subject, :boxes_count
    end
  end

  describe :portable= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :portable
    end

    it "accepts valid values" do
      _([nil, true, false]).must_be_written_to subject, :portable
    end
  end

  describe :slope_angle= do
    it "fails on invalid values" do
      _([:foobar, 123, AIXM.a('10'), AIXM.a(100)]).wont_be_written_to subject, :slope_angle
    end

    it "accepts valid values" do
      _([nil, AIXM.a(10)]).must_be_written_to subject, :slope_angle
    end
  end

  describe :meht= do
    it "fails on invalid values" do
      _([:foobar, 123, AIXM.z(10, :qnh)]).wont_be_written_to subject, :meht
    end

    it "accepts valid values" do
      _([nil, AIXM.z(10, :qfe)]).must_be_written_to subject, :meht
    end
  end

  describe :to_xml do
    it "builds correct complete AIXM/OFMX" do
      _(subject.to_xml).must_equal <<~END
        <codeTypeVasis>PAPI</codeTypeVasis>
        <codePsnVasis>BOTH</codePsnVasis>
        <noBoxVasis>2</noBoxVasis>
        <codePortableVasis>N</codePortableVasis>
        <valSlopeAngleGpVasis>6</valSlopeAngleGpVasis>
        <valMeht>100</valMeht>
        <uomMeht>FT</uomMeht>
      END
    end
  end
end
