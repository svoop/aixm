require_relative '../../../spec_helper'

describe AIXM::Component::Helipad do
  subject do
    AIXM::Factory.airport.helipads.first
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { _1.name = 'h1' }.name).must_equal 'H1'
    end
  end

  describe :xy= do
    macro :xy

    it "fails on nil value" do
      _([nil]).wont_be_written_to subject, :xy
    end
  end

  describe :z= do
    macro :z_qnh
  end

  describe :dimensions= do
    it "fails on invalid values" do
      _([:foobar, 0, 1, AIXM.d(0, :m)]).wont_be_written_to subject, :dimensions
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :dimensions
    end
  end

  describe :marking= do
    macro :marking
  end

  describe :helicopter_class= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :helicopter_class
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :helicopter_class
    end

    it "looks up valid values" do
      _(subject.tap { _1.helicopter_class = 1 }.helicopter_class).must_equal :'1'
      _(subject.tap { _1.helicopter_class = :OTHER }.helicopter_class).must_equal :other
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
        <Tla>
          <TlaUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <FtoUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
          <geoLat>43.99915000N</geoLat>
          <geoLong>004.75154444E</geoLong>
          <codeDatum>WGE</codeDatum>
          <valElev>141</valElev>
          <uomDistVer>FT</uomDistVer>
          <valLen>20</valLen>
          <valWid>20</valWid>
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
          <codeClassHel>1</codeClassHel>
          <txtMarking>Continuous white lines</txtMarking>
          <codeSts>OTHER</codeSts>
          <txtRmk>Authorizaton by AD operator required</txtRmk>
        </Tla>
        <Tls>
          <TlsUid>
            <TlaUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>H1</txtDesig>
            </TlaUid>
            <codePsn>AIM</codePsn>
          </TlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Tls>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(z dimensions helicopter_class marking status remarks).each { subject.send(:"#{_1}=", nil) }
      %i(composition preparation condition pcn siwl_weight siwl_tire_pressure auw_weight remarks).each { subject.surface.send(:"#{_1}=", nil) }
      subject.instance_eval { @lightings.clear }
      _(subject.to_xml).must_equal <<~END
        <Tla>
          <TlaUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <FtoUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </FtoUid>
          <geoLat>43.99915000N</geoLat>
          <geoLong>004.75154444E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Tla>
      END
    end
  end
end
