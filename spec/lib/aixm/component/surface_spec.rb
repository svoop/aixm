require_relative '../../../spec_helper'

describe AIXM::Component::Surface do
  subject do
    AIXM::Factory.airport.runways.first.surface
  end

  describe :composition= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :composition
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :composition
    end

    it "looks up valid values" do
      _(subject.tap { _1.composition = :macadam }.composition).must_equal :macadam
      _(subject.tap { _1.composition = :GRADE }.composition).must_equal :graded_earth
    end
  end

  describe :preparation= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :preparation
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :preparation
    end

    it "looks up valid values" do
      _(subject.tap { _1.preparation = :rolled }.preparation).must_equal :rolled
      _(subject.tap { _1.preparation = 'PFC' }.preparation).must_equal :porous_friction_course
    end
  end

  describe :condition= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :condition
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :condition
    end

    it "looks up valid values" do
      _(subject.tap { _1.condition = :fair }.condition).must_equal :fair
      _(subject.tap { _1.condition = :GOOD }.condition).must_equal :good
    end
  end

  describe :pcn do
  end

  describe :pcn= do
    it "fails on invalid values" do
      _([25, 'X/F/B/W/U', '10/A/B', '10/A/B/C/D']).wont_be_written_to subject, :pcn
    end

    it "accepts valid values" do
      _(subject.tap { _1.pcn = nil }.pcn).must_be :nil?
      _(subject.tap { _1.pcn = '25/F/B/W/U' }.pcn).must_equal '25/F/B/W/U'
      _(subject.tap { _1.pcn = '10 R C X T' }.pcn).must_equal '10/R/C/X/T'
      _(subject.tap { _1.pcn = "5\nF-b-y U" }.pcn).must_equal '5/F/B/Y/U'
    end
  end

  describe :siwl_weight= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :siwl_weight
    end

    it "accepts valid values" do
      _([nil, AIXM::Factory.w]).must_be_written_to subject, :siwl_weight
    end
  end

  describe :siwl_tire_pressure= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :siwl_tire_pressure
    end

    it "accepts valid values" do
      _([nil, AIXM::Factory.p]).must_be_written_to subject, :siwl_tire_pressure
    end
  end

  describe :auw_weight= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :auw_weight
    end

    it "accepts valid values" do
      _([nil, AIXM::Factory.w]).must_be_written_to subject, :auw_weight
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct complete AIXM/OFMX" do
      _(subject.to_xml).must_equal <<~END
        <codeComposition>ASPH</codeComposition>
        <codePreparation>PAVED</codePreparation>
        <codeCondSfc>GOOD</codeCondSfc>
        <valPcnClass>59</valPcnClass>
        <codePcnPavementType>F</codePcnPavementType>
        <codePcnPavementSubgrade>A</codePcnPavementSubgrade>
        <codePcnMaxTirePressure>W</codePcnMaxTirePressure>
        <codePcnEvalMethod>T</codePcnEvalMethod>
        <txtPcnNote>Paved shoulder on 2.5m on each side of the RWY.</txtPcnNote>
        <valSiwlWeight>1500</valSiwlWeight>
        <uomSiwlWeight>KG</uomSiwlWeight>
        <valSiwlTirePressure>0.5</valSiwlTirePressure>
        <uomSiwlTirePressure>MPA</uomSiwlTirePressure>
        <valAuwWeight>30</valAuwWeight>
        <uomAuwWeight>T</uomAuwWeight>
      END
    end
  end
end
