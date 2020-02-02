require_relative '../../../spec_helper'

describe AIXM::Feature::ObstacleGroup do
  describe "unlinked obstacle group" do
    subject do
      AIXM.obstacle_group(name: "Mirmande éoliennes")
    end

    describe :name= do
      it "fails on invalid values" do
        _([:foobar, 123]).wont_be_written_to subject, :name
      end

      it "upcases and transcodes valid values" do
        _(subject.name).must_equal 'MIRMANDE EOLIENNES'
      end
    end

    describe :xy_accuracy= do
      it "fails on invalid values" do
        _([:foobar, 123]).wont_be_written_to subject, :xy_accuracy
      end

      it "accepts valid values" do
        _([nil, AIXM::Factory.d, AIXM.d(0, :m)]).must_be_written_to subject, :xy_accuracy
      end
    end

    describe :z_accuracy= do
      it "fails on invalid values" do
        _([:foobar, 123]).wont_be_written_to subject, :z_accuracy
      end

      it "accepts valid values" do
        _([nil, AIXM::Factory.d, AIXM.d(0, :m)]).must_be_written_to subject, :z_accuracy
      end
    end

    describe :remarks= do
      macro :remarks
    end

    describe :to_xml do
      subject do
        AIXM::Factory.unlinked_obstacle_group
      end

      it "populates the mid attribute" do
        AIXM.ofmx!
        _(subject.mid).must_be :nil?
        subject.to_xml
        _(subject.mid).wont_be :nil?
      end

      it "builds correct AIXM" do
        _(subject.to_xml).must_equal <<~END
          <!-- Obstacle: [wind_turbine] 44.67501389N 004.87256667E LA TEISSONIERE 1 -->
          <Obs>
            <ObsUid>
              <geoLat>444030.05N</geoLat>
              <geoLong>0045221.24E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 1</txtName>
            <txtDescrType>WINDTURBINE</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1764</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67946667N 004.87381111E LA TEISSONIERE 2 -->
          <Obs>
            <ObsUid>
              <geoLat>444046.08N</geoLat>
              <geoLong>0045225.72E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 2</txtName>
            <txtDescrType>WINDTURBINE</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1738</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
        END
      end

      it "builds correct OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~END
          <!-- Obstacle group: MIRMANDE EOLIENNES -->
          <Ogr>
            <OgrUid region="LF">
              <txtName>MIRMANDE EOLIENNES</txtName>
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </OgrUid>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElevAccuracy>33</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <txtRmk>Extension planned</txtRmk>
          </Ogr>
          <!-- Obstacle: [wind_turbine] 44.67501389N 004.87256667E LA TEISSONIERE 1 -->
          <Obs>
            <ObsUid>
              <OgrUid region="LF">
                <txtName>MIRMANDE EOLIENNES</txtName>
                <geoLat>44.67501389N</geoLat>
                <geoLong>004.87256667E</geoLong>
              </OgrUid>
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 1</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>1764</valElev>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67946667N 004.87381111E LA TEISSONIERE 2 -->
          <Obs>
            <ObsUid>
              <OgrUid region="LF">
                <txtName>MIRMANDE EOLIENNES</txtName>
                <geoLat>44.67501389N</geoLat>
                <geoLong>004.87256667E</geoLong>
              </OgrUid>
              <geoLat>44.67946667N</geoLat>
              <geoLong>004.87381111E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 2</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>1738</valElev>
            <valHgt>262</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
        END
      end

      it "builds OFMX with mid" do
        AIXM.ofmx!
        AIXM.config.mid = true
        AIXM.config.region = 'LF'
        _(subject.to_xml).must_match /<OgrUid [^>]*? mid="ee8cb2a8-f482-5bbe-421f-272de41e1eec"/x
      end
    end
  end

  describe "linked obstacle group" do
    subject do
      AIXM.obstacle_group(name: "Mirmande éoliennes")
    end

    describe :add_obstacle do
      it "adds an obstacle to the obstacle group and links it to previous" do
        subject.add_obstacle(AIXM::Factory.obstacle)
        subject.add_obstacle(AIXM::Factory.obstacle, linked_to: :previous, link_type: :cable)
        _(subject.obstacles.count).must_equal 2
        _(subject.obstacles.last.linked_to).must_equal subject.obstacles.first
        _(subject.obstacles.last.link_type).must_equal :cable
      end

      it "adds an obstacle to the obstacle group and links it to another obstacle" do
        subject.add_obstacle(AIXM::Factory.obstacle)
        subject.add_obstacle(AIXM::Factory.obstacle, linked_to: subject.obstacles.first, link_type: :solid)
        _(subject.obstacles.count).must_equal 2
        _(subject.obstacles.last.linked_to).must_equal subject.obstacles.first
        _(subject.obstacles.last.link_type).must_equal :solid
      end
    end

    describe :to_xml do
      subject do
        AIXM::Factory.linked_obstacle_group
      end

      it "populates the mid attribute" do
        AIXM.ofmx!
        _(subject.mid).must_be :nil?
        subject.to_xml
        _(subject.mid).wont_be :nil?
      end

      it "builds correct AIXM" do
        _(subject.to_xml).must_equal <<~END
          <!-- Obstacle: [mast] 52.29639722N 002.10675278W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>521747.03N</geoLat>
              <geoLong>0020624.31W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <txtDescrType>MAST</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
          <!-- Obstacle: [mast] 52.29457778N 002.10568611W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>521740.48N</geoLat>
              <geoLong>0020620.47W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <txtDescrType>MAST</txtDescrType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
          </Obs>
        END
      end

      it "builds correct OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~END
          <!-- Obstacle group: DROITWICH LONGWAVE ANTENNA -->
          <Ogr>
            <OgrUid region="EG">
              <txtName>DROITWICH LONGWAVE ANTENNA</txtName>
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </OgrUid>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElevAccuracy>0</valElevAccuracy>
            <uomElevAccuracy>FT</uomElevAccuracy>
            <txtRmk>Destruction planned</txtRmk>
          </Ogr>
          <!-- Obstacle: [mast] 52.29639722N 002.10675278W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <OgrUid region="EG">
                <txtName>DROITWICH LONGWAVE ANTENNA</txtName>
                <geoLat>52.29639722N</geoLat>
                <geoLong>002.10675278W</geoLong>
              </OgrUid>
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>848</valElev>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
          </Obs>
          <!-- Obstacle: [mast] 52.29457778N 002.10568611W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <OgrUid region="EG">
                <txtName>DROITWICH LONGWAVE ANTENNA</txtName>
                <geoLat>52.29639722N</geoLat>
                <geoLong>002.10675278W</geoLong>
              </OgrUid>
              <geoLat>52.29457778N</geoLat>
              <geoLong>002.10568611W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeGroup>Y</codeGroup>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valElev>848</valElev>
            <valHgt>700</valHgt>
            <uomDistVer>FT</uomDistVer>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
            <ObsUidLink>
              <OgrUid region="EG">
                <txtName>DROITWICH LONGWAVE ANTENNA</txtName>
                <geoLat>52.29639722N</geoLat>
                <geoLong>002.10675278W</geoLong>
              </OgrUid>
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUidLink>
            <codeLinkType>CABLE</codeLinkType>
          </Obs>
        END
      end
    end
  end
end
