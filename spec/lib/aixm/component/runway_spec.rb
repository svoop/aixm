require_relative '../../../spec_helper'

describe AIXM::Component::Runway do
  subject do
    AIXM::Factory.airport.runways.first
  end

  describe :initialize do
    it "sets defaults for bidirectional runways" do
      subject.forth.name.must_equal AIXM.a('16L')
      subject.back.name.must_equal AIXM.a('34R')
    end

    it "sets defaults for unidirectional runways" do
      subject = AIXM::Component::Runway.new(name: '30')
      subject.forth.name.must_equal AIXM.a('30')
      subject.back.must_be_nil
    end

    it "fails on non-inverse bidirectional runways" do
      -> { AIXM.runway(name: '16L/14R') }.must_raise ArgumentError
    end
  end

  describe :name= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = '10r/28l' }.name.must_equal '10R/28L'
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
        <Rwy>
          <RwyUid>
            <AhpUid>
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
          <txtRmk>Markings eroded</txtRmk>
        </Rwy>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
          <valTrueBrg>165</valTrueBrg>
          <valMagBrg>166</valMagBrg>
          <valElevTdz>145</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeVfrPattern>E</codeVfrPattern>
          <txtRmk>forth remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid>
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
                <AhpUid>
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
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>34R</txtDesig>
          </RdnUid>
          <geoLat>43.99036389N</geoLat>
          <geoLong>004.75645556E</geoLong>
          <valTrueBrg>345</valTrueBrg>
          <valMagBrg>346</valMagBrg>
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeVfrPattern>L</codeVfrPattern>
          <txtRmk>back remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid>
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
                <AhpUid>
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
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(length width status remarks).each { |a| subject.send(:"#{a}=", nil) }
      %i(composition preparation condition pcn siwl_weight siwl_tire_pressure auw_weight remarks).each { |a| subject.surface.send(:"#{a}=", nil) }
      %i(forth back).each { |d| subject.send(d).instance_eval { @lightings.clear } }
      subject.to_xml.must_equal <<~END
        <Rwy>
          <RwyUid>
            <AhpUid>
              <codeId>LFNT</codeId>
            </AhpUid>
            <txtDesig>16L/34R</txtDesig>
          </RwyUid>
        </Rwy>
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
          <valTrueBrg>165</valTrueBrg>
          <valMagBrg>166</valMagBrg>
          <valElevTdz>145</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeVfrPattern>E</codeVfrPattern>
          <txtRmk>forth remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid>
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
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>34R</txtDesig>
          </RdnUid>
          <geoLat>43.99036389N</geoLat>
          <geoLong>004.75645556E</geoLong>
          <valTrueBrg>345</valTrueBrg>
          <valMagBrg>346</valMagBrg>
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeVfrPattern>L</codeVfrPattern>
          <txtRmk>back remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid>
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
      [nil, :foobar, '16R'].wont_be_written_to subject, :name
    end

    it "overwrites preset name" do
      subject.name.to_s.must_equal '16L'
      subject.name = AIXM.a('34L')
      subject.name.to_s.must_equal '34L'
    end
  end

  describe :geographic_orientation= do
    it "fails on invalid values" do
      [:foobar, -1, 10].wont_be_written_to subject, :geographic_orientation
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

    it "accepts nil value" do
      [nil].must_be_written_to subject, :z
    end
  end

  describe :displaced_threshold= do
    it "fails on invalid values" do
      [:foobar, 1, AIXM.d(0, :m)].wont_be_written_to subject, :displaced_threshold
    end

    it "converts coordinates to distance" do
      subject.xy = AIXM.xy(lat: %q(43°59'54.71"N), long: %q(004°45'28.35"E))
      subject.displaced_threshold = AIXM.xy(lat: %q(43°59'48.47"N), long: %q(004°45'30.62"E))
      subject.displaced_threshold.must_equal AIXM.d(199, :m)
    end
  end

  describe :vfr_pattern= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :vfr_pattern
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :vfr_pattern
    end

    it "looks up valid values" do
      subject.tap { |s| s.vfr_pattern = :left }.vfr_pattern.must_equal :left
      subject.tap { |s| s.vfr_pattern = :E }.vfr_pattern.must_equal :left_or_right
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :magnetic_orientation do
    it "is calculated correctly" do
      subject.geographic_orientation = AIXM.a(16)
      subject.magnetic_orientation.must_equal AIXM.a(17)
    end
  end

  describe :xml= do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid>
                <codeId>LFNT</codeId>
              </AhpUid>
              <txtDesig>16L/34R</txtDesig>
            </RwyUid>
            <txtDesig>16L</txtDesig>
          </RdnUid>
          <geoLat>44.00211944N</geoLat>
          <geoLong>004.75216944E</geoLong>
          <valTrueBrg>165</valTrueBrg>
          <valMagBrg>166</valMagBrg>
          <valElevTdz>145</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
          <codeVfrPattern>E</codeVfrPattern>
          <txtRmk>forth remarks</txtRmk>
        </Rdn>
        <Rdd>
          <RddUid>
            <RdnUid>
              <RwyUid>
                <AhpUid>
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
                <AhpUid>
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
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(geographic_orientation z displaced_threshold vfr_pattern remarks).each { |a| subject.send(:"#{a}=", nil) }
      subject.instance_eval { @lightings.clear }
      subject.to_xml.must_equal <<~END
        <Rdn>
          <RdnUid>
            <RwyUid>
              <AhpUid>
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
