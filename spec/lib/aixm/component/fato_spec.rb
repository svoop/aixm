require_relative '../../../spec_helper'

describe AIXM::Component::FATO do
  subject do
    AIXM::Factory.airport.fatos.first
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { _1.name = 'h1' }.name).must_equal 'H1'
    end
  end

  describe :length= do
    it "fails on invalid values" do
      _([:foobar, 0, 1, AIXM.d(0, :m)]).wont_be_written_to subject, :length
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :length
    end
  end

  describe :width= do
    it "fails on invalid values" do
      _([:foobar, 0, 1, AIXM.d(0, :m)]).wont_be_written_to subject, :width
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :width
    end
  end

  describe :marking= do
    macro :marking
  end

  describe :profile= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :profile
    end

    it "stringifies valid values" do
      _(subject.tap { _1.profile = 'foobar' }.profile).must_equal 'foobar'
      _(subject.tap { _1.profile = 123 }.profile).must_equal '123'
    end
  end

  describe :status= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :status
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :status
    end

    it "looks up valid values" do
      _(subject.tap { _1.status = :closed }.status).must_equal :closed
      _(subject.tap { _1.status = :SPOWER }.status).must_equal :secondary_power
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <Fto>
          <FtoUid>
            <AhpUid region="LF">
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
        <Fdn>
          <FdnUid>
            <FtoUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </FtoUid>
            <txtDesig>35</txtDesig>
          </FdnUid>
          <valTrueBrg>355</valTrueBrg>
          <valMagBrg>354</valMagBrg>
          <txtRmk>Avoid flight over residental area</txtRmk>
        </Fdn>
        <Fls>
          <FlsUid>
            <FdnUid>
              <FtoUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>H1</txtDesig>
              </FtoUid>
              <txtDesig>35</txtDesig>
            </FdnUid>
            <codePsn>AIM</codePsn>
          </FlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Fls>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(length width profile marking status remarks).each { subject.send(:"#{_1}=", nil) }
      %i(composition preparation condition pcn siwl_weight siwl_tire_pressure auw_weight remarks).each { subject.surface.send(:"#{_1}=", nil) }
      subject.directions.first.instance_eval { @lightings.clear }
      _(subject.to_xml).must_equal <<~END
        <Fto>
          <FtoUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
        </Fto>
        <Fdn>
          <FdnUid>
            <FtoUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </FtoUid>
            <txtDesig>35</txtDesig>
          </FdnUid>
          <valTrueBrg>355</valTrueBrg>
          <valMagBrg>354</valMagBrg>
          <txtRmk>Avoid flight over residental area</txtRmk>
        </Fdn>
      END
    end
  end
end

describe AIXM::Component::FATO::Direction do
  subject do
    AIXM::Factory.airport.fatos.first.directions.first
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, :foobar, 'OGGY']).wont_be_written_to subject, :name
    end
  end

  describe :geographic_orientation= do
    it "fails on invalid values" do
      _([:foobar, -1, 10]).wont_be_written_to subject, :geographic_orientation
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :magnetic_orientation do
    it "is calculated correctly" do
      subject.geographic_orientation = AIXM.a(16)
      _(subject.magnetic_orientation).must_equal AIXM.a(15)
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <Fdn>
          <FdnUid>
            <FtoUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </FtoUid>
            <txtDesig>35</txtDesig>
          </FdnUid>
          <valTrueBrg>355</valTrueBrg>
          <valMagBrg>354</valMagBrg>
          <txtRmk>Avoid flight over residental area</txtRmk>
        </Fdn>
        <Fls>
          <FlsUid>
            <FdnUid>
              <FtoUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>H1</txtDesig>
              </FtoUid>
              <txtDesig>35</txtDesig>
            </FdnUid>
            <codePsn>AIM</codePsn>
          </FlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Fls>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(geographic_orientation remarks).each { subject.send(:"#{_1}=", nil) }
      subject.instance_eval { @lightings.clear }
      _(subject.to_xml).must_equal <<~END
      <Fdn>
        <FdnUid>
          <FtoUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
          <txtDesig>35</txtDesig>
        </FdnUid>
      </Fdn>
      END
    end
  end
end
