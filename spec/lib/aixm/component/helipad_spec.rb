require_relative '../../../spec_helper'

describe AIXM::Component::Helipad do
  subject do
    AIXM::Factory.airport.helipads.first
  end

  describe :name= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'h1' }.name.must_equal 'H1'
    end
  end

  describe :xy= do
    macro :xy

    it "fails on nil value" do
      [nil].wont_be_written_to subject, :xy
    end
  end

  describe :z= do
    macro :z_qnh
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

  describe :fato= do
    it "fails on invalid values" do
      [:foobar, 0].wont_be_written_to subject, :fato
    end

    it "accepts valid values" do
      [nil, AIXM::Factory.fato].must_be_written_to subject, :fato
    end
  end

  describe :helicopter_class= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :helicopter_class
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :helicopter_class
    end

    it "looks up valid values" do
      subject.tap { |s| s.helicopter_class = 1 }.helicopter_class.must_equal :'1'
      subject.tap { |s| s.helicopter_class = :OTHER }.helicopter_class.must_equal :other
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
        <Tla>
          <TlaUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <FtoUid>
            <AhpUid>
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
          <codeClassHel>1</codeClassHel>
          <txtMarking>Continuous white lines</txtMarking>
          <codeSts>OTHER</codeSts>
          <txtRmk>Authorizaton by AD operator required</txtRmk>
        </Tla>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(z length width helicopter_class marking status remarks).each { |a| subject.send(:"#{a}=", nil) }
      %i(composition preparation condition pcn remarks).each { |a| subject.surface.send(:"#{a}=", nil) }
      subject.to_xml.must_equal <<~END
        <Tla>
          <TlaUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <FtoUid>
            <AhpUid>
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
