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

  describe :center_line do
    it "returns a line instance" do
      _(subject.center_line).must_be_instance_of AIXM::L
    end

    context "bidirectional runway" do
      subject do
        AIXM::Factory.runway
      end

      it "describes the center line forth edge" do
        _(subject.center_line.line_points.first.xy).must_equal AIXM.xy(lat: %q(43°59'54.71"N), long: %q(004°45'28.35"E))
      end

      it "describes the center line back edge" do
        _(subject.center_line.line_points.last.xy).must_equal AIXM.xy(lat: %q(43°59'34.33"N), long: %q(004°45'35.74"E))
      end
    end

    context "unidirectional runway with dimensions" do
      subject do
        AIXM::Factory.runway.tap { _1.back = nil }
      end

      it "describes the center line forth edge" do
        _(subject.center_line.line_points.first.xy).must_equal AIXM.xy(lat: %q(43°59'54.71"N), long: %q(004°45'28.35"E))
      end

      it "describes the calculated center line back edge" do
        exact = AIXM.xy(lat: %q(43°59'34.33"N), long: %q(004°45'35.74"E))
        _(subject.center_line.line_points.last.xy.lat).must_be_close_to(exact.lat, 0.00006)     # approx 8m tolerance
        _(subject.center_line.line_points.last.xy.long).must_be_close_to(exact.long, 0.00006)   # approx 8m tolerance
      end
    end

    context "unidirectional runway without dimensions" do
      subject do
        AIXM::Factory.runway.tap { _1.back = _1.dimensions = nil }
      end

      it "cannot calculate center line and returns nil" do
        _(subject.center_line).must_be :nil?
      end
    end
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
        <Rcp>
          <RcpUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <geoLat>43.99853056N</geoLat>
            <geoLong>004.75787500E</geoLong>
          </RcpUid>
          <codeDatum>WGE</codeDatum>
          <valElev>144</valElev>
          <uomDistVer>FT</uomDistVer>
        </Rcp>
        <Rcp>
          <RcpUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <geoLat>43.99286944N</geoLat>
            <geoLong>004.75992778E</geoLong>
          </RcpUid>
          <codeDatum>WGE</codeDatum>
          <valElev>148</valElev>
          <uomDistVer>FT</uomDistVer>
        </Rcp>
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
          <geoLat>43.99679722N</geoLat>
          <geoLong>004.75850556E</geoLong>
          <valTrueBrg>165.0000</valTrueBrg>
          <valMagBrg>163.9200</valMagBrg>
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
          <valDist>199</valDist>
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
          <geoLat>43.99468889N</geoLat>
          <geoLong>004.75926944E</geoLong>
          <valTrueBrg>345.0000</valTrueBrg>
          <valMagBrg>343.9200</valMagBrg>
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
        <Rcp>
          <RcpUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <geoLat>43.99853056N</geoLat>
            <geoLong>004.75787500E</geoLong>
          </RcpUid>
          <codeDatum>WGE</codeDatum>
          <valElev>144</valElev>
          <uomDistVer>FT</uomDistVer>
        </Rcp>
        <Rcp>
          <RcpUid>
            <RwyUid>
              <AhpUid region="LF">
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <geoLat>43.99286944N</geoLat>
            <geoLong>004.75992778E</geoLong>
          </RcpUid>
          <codeDatum>WGE</codeDatum>
          <valElev>148</valElev>
          <uomDistVer>FT</uomDistVer>
        </Rcp>
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
          <geoLat>43.99679722N</geoLat>
          <geoLong>004.75850556E</geoLong>
          <valTrueBrg>165.0000</valTrueBrg>
          <valMagBrg>163.9200</valMagBrg>
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
          <valDist>199</valDist>
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
          <geoLat>43.99468889N</geoLat>
          <geoLong>004.75926944E</geoLong>
          <valTrueBrg>345.0000</valTrueBrg>
          <valMagBrg>343.9200</valMagBrg>
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
      _(subject.name.to_s(:runway)).must_equal '16L'
      subject.name = AIXM.a('34L')
      _(subject.name.to_s(:runway)).must_equal '34L'
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

  context "displaced threshold as distance or coordinates" do
    let :distance do
      AIXM.d(199, :m)
    end

    let :coordinates do
      AIXM.xy(lat: %q(43°59'48.47"N), long: %q(004°45'30.62"E))
    end

    describe :displaced_threshold= do
      it "fails on invalid values" do
        _([:foobar, 1, AIXM.d(0, :m), AIXM::Factory.xy]).wont_be_written_to subject, :displaced_threshold
      end

      it "accepts distance and converts it to coordinates" do
        subject.displaced_threshold = distance
        _(subject.displaced_threshold).must_equal distance
        _(subject.displaced_threshold_xy.lat).must_be_close_to(coordinates.lat, 0.000015)     # approx 2m tolerance
        _(subject.displaced_threshold_xy.long).must_be_close_to(coordinates.long, 0.000015)   # approx 2m tolerance
      end

      it "fails if xy is not set" do
        subject.instance_variable_set(:@xy, nil)
        _{ subject.displaced_threshold = distance }.must_raise RuntimeError
      end

      it "fails if bearing is not set" do
        subject.geographic_bearing = nil
        _{ subject.displaced_threshold = distance }.must_raise RuntimeError
      end
    end

    describe :displaced_threshold_xy= do
      it "fails on invalid values" do
        _([:foobar, 1, AIXM::Factory.d]).wont_be_written_to subject, :displaced_threshold_xy
      end

      it "accepts coordinates and converts it to distance" do
        subject.displaced_threshold_xy = coordinates
        _(subject.displaced_threshold_xy).must_equal coordinates
        _(subject.displaced_threshold).must_equal distance
      end

      it "fails if xy is not set" do
        subject.instance_variable_set(:@xy, nil)
        _{ subject.displaced_threshold_xy = coordinates }.must_raise RuntimeError
      end
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
      _(subject.magnetic_bearing.to_s(:bearing)).must_equal '014.9200'
    end

    it "is formatted correctly" do
      subject.geographic_bearing = AIXM.a(16)
      _(subject.to_xml).must_match %r(<valMagBrg>014.9200</valMagBrg>)
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
          <geoLat>43.99679722N</geoLat>
          <geoLong>004.75850556E</geoLong>
          <valTrueBrg>165.0000</valTrueBrg>
          <valMagBrg>163.9200</valMagBrg>
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
          <valDist>199</valDist>
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
      %i(geographic_bearing z touch_down_zone_z displaced_threshold vasis vfr_pattern remarks).each { subject.send(:"#{_1}=", nil) }
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
          <geoLat>43.99853056N</geoLat>
          <geoLong>004.75787500E</geoLong>
        </Rdn>
      END
    end
  end
end
