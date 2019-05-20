require_relative '../../../spec_helper'

describe AIXM::Component::FATO do
  subject do
    AIXM::Factory.airport.fatos.first
  end

  describe :name= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'h1' }.name.must_equal 'H1'
    end
  end

  describe :length= do
    it "fails on invalid values" do
      [:foobar, 0, 1, AIXM.d(0, :m)].wont_be_written_to subject, :length
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :length
    end
  end

  describe :width= do
    it "fails on invalid values" do
      [:foobar, 0, 1, AIXM.d(0, :m)].wont_be_written_to subject, :width
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :width
    end
  end

  describe :marking= do
    macro :marking
  end

  describe :profile= do
    it "accepts nil value" do
      [nil].must_be_written_to subject, :profile
    end

    it "stringifies valid values" do
      subject.tap { |s| s.profile = 'foobar' }.profile.must_equal 'foobar'
      subject.tap { |s| s.profile = 123 }.profile.must_equal '123'
    end
  end

  describe :status= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :status
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :status
    end

    it "looks up valid values" do
      subject.tap { |s| s.status = :closed }.status.must_equal :closed
      subject.tap { |s| s.status = :SPOWER }.status.must_equal :secondary_power
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :xml= do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <Fto>
          <FtoUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
          <valLen>35</valLen>
          <valWid>35</valWid>
          <uomDim>M</uomDim>
          <codeComposition>CONC</codeComposition>
          <codePreparation>PAVED</codePreparation>
          <codeCondSfc>FAIR</codeCondSfc>
          <valPcnClass>30</valPcnClass>
          <codePcnPavementType>F</codePcnPavementType>
          <codePcnPavementSubgrade>A</codePcnPavementSubgrade>
          <codePcnMaxTirePressure>W</codePcnMaxTirePressure>
          <codePcnEvalMethod>U</codePcnEvalMethod>
          <txtPcnNote>Cracks near the center</txtPcnNote>
          <valSiwlWeight>1500</valSiwlWeight>
          <uomSiwlWeight>KG</uomSiwlWeight>
          <valSiwlTirePressure>0.5</valSiwlTirePressure>
          <uomSiwlTirePressure>MPA</uomSiwlTirePressure>
          <valAuwWeight>8</valAuwWeight>
          <uomAuwWeight>T</uomAuwWeight>
          <txtProfile>Northwest from RWY 12/30</txtProfile>
          <txtMarking>Dashed white lines</txtMarking>
          <codeSts>OTHER</codeSts>
          <txtRmk>Authorizaton by AD operator required</txtRmk>
        </Fto>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(length width profile marking status remarks).each { |a| subject.send(:"#{a}=", nil) }
      %i(composition preparation condition pcn siwl_weight siwl_tire_pressure auw_weight remarks).each { |a| subject.surface.send(:"#{a}=", nil) }
      subject.to_xml.must_equal <<~END
        <Fto>
          <FtoUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
        </Fto>
      END
    end
  end
end
