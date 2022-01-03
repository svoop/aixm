require_relative '../../../spec_helper'

describe AIXM::Component::Runway do
  subject do
    AIXM::Factory.airport.runways.first
  end

  describe :initialize do
    it "sets defaults for bidirectional runways" do
      _(subject.forth.name).must_equal AIXM.a('16L')
      _(subject.back.name).must_equal AIXM.a('34R')
    end

    it "sets defaults for unidirectional runways" do
      subject = AIXM::Component::Runway.new(name: '30')
      _(subject.forth.name).must_equal AIXM.a('30')
      _(subject.back).must_be_nil
    end

    it "fails on non-inverse bidirectional runways" do
      _{ AIXM.runway(name: '16L/14R') }.must_raise ArgumentError
    end
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { _1.name = '10r/28l' }.name).must_equal '10R/28L'
    end
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
        <Rwy>
          <RwyUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>16L/34R</txtDesig>
          </RwyUid>
          <valLen>650</valLen>
          <valWid>80</valWid>
          <uomDimRwy>M</uomDimRwy>
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
          <codeSts>CLSD</codeSts>
          <txtMarking>Standard marking</txtMarking>
          <txtRmk>Markings eroded</txtRmk>
        </Rwy>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
          <valTrueBrg>165.0</valTrueBrg>
          <valMagBrg>163.92</valMagBrg>
          <valElevTdz>145</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeTypeVasis>PAPI</codeTypeVasis>
          <codePsnVasis>BOTH</codePsnVasis>
          <noBoxVasis>2</noBoxVasis>
          <codePortableVasis>N</codePortableVasis>
          <valSlopeAngleGpVasis>5.7</valSlopeAngleGpVasis>
          <valMeht>100</valMeht>
          <uomMeht>FT</uomMeht>
          <codeVfrPattern>E</codeVfrPattern>
          <txtRmk>forth remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codeType>DPLM</codeType>
            <codeDayPeriod>A</codeDayPeriod>
          </RddUid>
          <valDist>131</valDist>
          <uomDist>M</uomDist>
          <txtRmk>forth remarks</txtRmk>
        </Rdd>
        <Rls>
          <RlsUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codePsn>AIM</codePsn>
          </RlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Rls>
        <Rda>
          <RdaUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codeType>A</codeType>
          </RdaUid>
          <valLen>1000</valLen>
          <uomLen>M</uomLen>
          <codeIntst>LIH</codeIntst>
          <codeSequencedFlash>N</codeSequencedFlash>
          <txtDescrFlash>three grouped bursts</txtDescrFlash>
          <txtRmk>on demand</txtRmk>
        </Rda>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>34R</txtDesig>
          </RdnUid>
          <geoLat>43.99036389N</geoLat>
          <geoLong>004.75645556E</geoLong>
          <valTrueBrg>345.0</valTrueBrg>
          <valMagBrg>343.92</valMagBrg>
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeTypeVasis>PAPI</codeTypeVasis>
          <codePsnVasis>BOTH</codePsnVasis>
          <noBoxVasis>2</noBoxVasis>
          <codePortableVasis>N</codePortableVasis>
          <valSlopeAngleGpVasis>5.7</valSlopeAngleGpVasis>
          <valMeht>100</valMeht>
          <uomMeht>FT</uomMeht>
          <codeVfrPattern>L</codeVfrPattern>
          <txtRmk>back remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>34R</txtDesig>
            </RdnUid>
            <codeType>DPLM</codeType>
            <codeDayPeriod>A</codeDayPeriod>
          </RddUid>
          <valDist>209</valDist>
          <uomDist>M</uomDist>
          <txtRmk>back remarks</txtRmk>
        </Rdd>
        <Rls>
          <RlsUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>34R</txtDesig>
            </RdnUid>
            <codePsn>AIM</codePsn>
          </RlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Rls>
        <Rda>
          <RdaUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>34R</txtDesig>
            </RdnUid>
            <codeType>A</codeType>
          </RdaUid>
          <valLen>1000</valLen>
          <uomLen>M</uomLen>
          <codeIntst>LIH</codeIntst>
          <codeSequencedFlash>N</codeSequencedFlash>
          <txtDescrFlash>three grouped bursts</txtDescrFlash>
          <txtRmk>on demand</txtRmk>
        </Rda>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(dimensions marking status remarks).each { subject.send(:"#{_1}=", nil) }
      %i(composition preparation condition pcn siwl_weight siwl_tire_pressure auw_weight remarks).each { subject.surface.send(:"#{_1}=", nil) }
      %i(forth back).each do
        subject.send(_1).instance_eval do
          @lightings.clear
          @approach_lightings.clear
        end
      end
      _(subject.to_xml).must_equal <<~END
        <Rwy>
          <RwyUid>
            <AhpUid region="LF">
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>16L/34R</txtDesig>
          </RwyUid>
        </Rwy>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
          <valTrueBrg>165.0</valTrueBrg>
          <valMagBrg>163.92</valMagBrg>
          <valElevTdz>145</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeTypeVasis>PAPI</codeTypeVasis>
          <codePsnVasis>BOTH</codePsnVasis>
          <noBoxVasis>2</noBoxVasis>
          <codePortableVasis>N</codePortableVasis>
          <valSlopeAngleGpVasis>5.7</valSlopeAngleGpVasis>
          <valMeht>100</valMeht>
          <uomMeht>FT</uomMeht>
          <codeVfrPattern>E</codeVfrPattern>
          <txtRmk>forth remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codeType>DPLM</codeType>
            <codeDayPeriod>A</codeDayPeriod>
          </RddUid>
          <valDist>131</valDist>
          <uomDist>M</uomDist>
          <txtRmk>forth remarks</txtRmk>
        </Rdd>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>34R</txtDesig>
          </RdnUid>
          <geoLat>43.99036389N</geoLat>
          <geoLong>004.75645556E</geoLong>
          <valTrueBrg>345.0</valTrueBrg>
          <valMagBrg>343.92</valMagBrg>
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeTypeVasis>PAPI</codeTypeVasis>
          <codePsnVasis>BOTH</codePsnVasis>
          <noBoxVasis>2</noBoxVasis>
          <codePortableVasis>N</codePortableVasis>
          <valSlopeAngleGpVasis>5.7</valSlopeAngleGpVasis>
          <valMeht>100</valMeht>
          <uomMeht>FT</uomMeht>
          <codeVfrPattern>L</codeVfrPattern>
          <txtRmk>back remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>34R</txtDesig>
            </RdnUid>
            <codeType>DPLM</codeType>
            <codeDayPeriod>A</codeDayPeriod>
          </RddUid>
          <valDist>209</valDist>
          <uomDist>M</uomDist>
          <txtRmk>back remarks</txtRmk>
        </Rdd>
      END
    end
  end
end

describe AIXM::Component::Runway::Direction do
  subject do
    AIXM::Factory.airport.runways.first.forth
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, :foobar, '16R']).wont_be_written_to subject, :name
    end

    it "overwrites preset name" do
      _(subject.name.to_runway).must_equal '16L'
      subject.name = AIXM.a('34L')
      _(subject.name.to_runway).must_equal '34L'
    end
  end

  describe :geographic_bearing= do
    it "fails on invalid values" do
      _([:foobar, -1, 10]).wont_be_written_to subject, :geographic_bearing
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

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :z
    end
  end

  describe :displaced_threshold= do
    it "fails on invalid values" do
      _([:foobar, 1, AIXM.d(0, :m)]).wont_be_written_to subject, :displaced_threshold
    end

    it "converts coordinates to distance" do
      subject.xy = AIXM.xy(lat: %q(43°59'54.71"N), long: %q(004°45'28.35"E))
      subject.displaced_threshold = AIXM.xy(lat: %q(43°59'48.47"N), long: %q(004°45'30.62"E))
      _(subject.displaced_threshold).must_equal AIXM.d(199, :m)
    end
  end

  describe :vasis= do
    it "fails on invalid vlues" do
      _([:foobar, 5]).wont_be_written_to subject, :vasis
    end
  end

  describe :vfr_pattern= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :vfr_pattern
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :vfr_pattern
    end

    it "looks up valid values" do
      _(subject.tap { _1.vfr_pattern = :left }.vfr_pattern).must_equal :left
      _(subject.tap { _1.vfr_pattern = :E }.vfr_pattern).must_equal :left_or_right
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :magnetic_bearing do
    it "is calculated correctly" do
      subject.geographic_bearing = AIXM.a(16)
      _(subject.magnetic_bearing.to_bearing).must_equal 14.92
    end
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
          <valTrueBrg>165.0</valTrueBrg>
          <valMagBrg>163.92</valMagBrg>
          <valElevTdz>145</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeTypeVasis>PAPI</codeTypeVasis>
          <codePsnVasis>BOTH</codePsnVasis>
          <noBoxVasis>2</noBoxVasis>
          <codePortableVasis>N</codePortableVasis>
          <valSlopeAngleGpVasis>5.7</valSlopeAngleGpVasis>
          <valMeht>100</valMeht>
          <uomMeht>FT</uomMeht>
          <codeVfrPattern>E</codeVfrPattern>
          <txtRmk>forth remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codeType>DPLM</codeType>
            <codeDayPeriod>A</codeDayPeriod>
          </RddUid>
          <valDist>131</valDist>
          <uomDist>M</uomDist>
          <txtRmk>forth remarks</txtRmk>
        </Rdd>
        <Rls>
          <RlsUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codePsn>AIM</codePsn>
          </RlsUid>
          <txtDescr>omnidirectional</txtDescr>
          <codeIntst>LIM</codeIntst>
          <codeColour>GRN</codeColour>
          <txtRmk>lighting remarks</txtRmk>
        </Rls>
        <Rda>
          <RdaUid>
            <RdnUid>
              <RwyUid>
                <AhpUid region="LF">
                  <codeId>LFNT</codeId>
                </AhpUid>
                <txtDesig>16L/34R</txtDesig>
              </RwyUid>
              <txtDesig>16L</txtDesig>
            </RdnUid>
            <codeType>A</codeType>
          </RdaUid>
          <valLen>1000</valLen>
          <uomLen>M</uomLen>
          <codeIntst>LIH</codeIntst>
          <codeSequencedFlash>N</codeSequencedFlash>
          <txtDescrFlash>three grouped bursts</txtDescrFlash>
          <txtRmk>on demand</txtRmk>
        </Rda>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(geographic_bearing z displaced_threshold vasis vfr_pattern remarks).each { subject.send(:"#{_1}=", nil) }
      subject.instance_eval do
        @lightings.clear
        @approach_lightings.clear
      end
      _(subject.to_xml).must_equal <<~END
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
        </Rdn>
      END
    end
  end
end
