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

  describe :preparation= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :preparation
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :preparation
    end

    it "looks up valid values" do
      subject.tap { |s| s.preparation = :rolled }.preparation.must_equal :rolled
      subject.tap { |s| s.preparation = :NATURAL }.preparation.must_equal :no_treatment
    end
  end

  describe :condition= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :condition
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :condition
    end

    it "looks up valid values" do
      subject.tap { |s| s.condition = :fair }.condition.must_equal :fair
      subject.tap { |s| s.condition = :GOOD }.condition.must_equal :good
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
          <codeComposition>GRADE</codeComposition>
          <codePreparation>ROLLED</codePreparation>
          <codeCondSfc>FAIR</codeCondSfc>
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
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
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

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(length width composition preparation condition status remarks).each { |a| subject.send(:"#{a}=", nil) }
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
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
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
          <valElevTdz>147</valElevTdz>
          <uomElevTdz>FT</uomElevTdz>
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
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      %i(geographic_orientation z displaced_threshold remarks).each { |a| subject.send(:"#{a}=", nil) }
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
