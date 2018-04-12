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
      [:foobar, 0, -1].wont_be_written_to subject, :length
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :length
    end

    it "converts valid Numeric values to Integer" do
      subject.tap { |s| s.length = 1000.5 }.length.must_equal 1000
    end
  end

  describe :width= do
    it "fails on invalid values" do
      [:foobar, 0, -1].wont_be_written_to subject, :width
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :width
    end

    it "converts valid Numeric values to Integer" do
      subject.tap { |s| s.width = 150.5 }.width.must_equal 150
    end
  end

  describe :composition= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :composition
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :composition
    end

    it "looks up valid values" do
      subject.tap { |s| s.composition = :macadam }.composition.must_equal :macadam
      subject.tap { |s| s.composition = :GRADE }.composition.must_equal :graded_earth
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
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <geoLat>43.99915000N</geoLat>
          <geoLong>004.75154444E</geoLong>
          <codeDatum>WGE</codeDatum>
          <valElev>141</valElev>
          <uomDistVer>FT</uomDistVer>
          <valLen>20</valLen>
          <valWid>20</valWid>
          <uomDim>M</uomDim>
          <codeComposition>GRASS</codeComposition>
          <codeSts>OTHER</codeSts>
          <txtRmk>Authorizaton by AD operator required</txtRmk>
        </Tla>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.z = subject.length = subject.width = subject.composition = subject.status = subject.remarks = nil
      subject.to_xml.must_equal <<~END
        <Tla>
          <TlaUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>H1</txtDesig>
          </TlaUid>
          <geoLat>43.99915000N</geoLat>
          <geoLong>004.75154444E</geoLong>
          <codeDatum>WGE</codeDatum>
        </Tla>
      END
    end
  end
end
