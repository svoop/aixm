require_relative '../../../spec_helper'

describe AIXM::Feature::ObstacleGroup do
  describe "unlinked group" do
    subject do
      AIXM.obstacle_group(name: "Mirmande éoliennes")
    end

    describe :initialize do
      it "sets defaults" do
        subject = AIXM.obstacle_group(
          name: "Mirmande éoliennes"
        )
        subject.obstacles.must_equal []
      end
    end

    describe :name= do
      it "fails on invalid values" do
        [:foobar, 123].wont_be_written_to subject, :name
      end

      it "upcases and transcodes valid values" do
        subject.name.must_equal 'MIRMANDE EOLIENNES'
      end
    end

    describe :add_obstacle do
      it "adds an obstacle to the group" do
        subject.add_obstacle(AIXM::Factory.obstacle)
        subject.obstacles.count.must_equal 1
        subject.obstacles.first.must_be :grouped?
        subject.obstacles.first.group.must_equal subject
      end
    end

    describe :id do
      subject do
        AIXM::Factory.unlinked_obstacle_group
      end

      it "is derived from the group name" do
        subject.id.must_equal '462c8d00-981a-0995-09aa-4ba39161bb41'
        subject.name = 'Oggy'
        subject.id.must_equal '939de24d-941b-d5a6-3437-df135ddb9906'
      end

      it "is derived from the xy of the group obstacles" do
        subject.id.must_equal '462c8d00-981a-0995-09aa-4ba39161bb41'
        subject.obstacles.first.xy.long = 1
        subject.id.must_equal '819d6977-5301-14d3-6d2e-1de007d922e1'
      end
    end

    describe :to_xml do
      subject do
        AIXM::Factory.unlinked_obstacle_group
      end

      it "builds correct AIXM" do
        AIXM.aixm!
        subject.to_xml.must_equal <<~END
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
        subject.to_xml.must_equal <<~END
          <!-- Obstacle: [wind_turbine] 44.67501389N 004.87256667E LA TEISSONIERE 1 -->
          <Obs>
            <ObsUid>
              <geoLat>44.67501389N</geoLat>
              <geoLong>004.87256667E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 1</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1764</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>462c8d00-981a-0995-09aa-4ba39161bb41</codeGroupId>
            <txtGroupName>MIRMANDE EOLIENNES</txtGroupName>
          </Obs>
          <!-- Obstacle: [wind_turbine] 44.67946667N 004.87381111E LA TEISSONIERE 2 -->
          <Obs>
            <ObsUid>
              <geoLat>44.67946667N</geoLat>
              <geoLong>004.87381111E</geoLong>
            </ObsUid>
            <txtName>LA TEISSONIERE 2</txtName>
            <codeType>WINDTURBINE</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>50</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>1738</valElev>
            <valElevAccuracy>33</valElevAccuracy>
            <valHgt>262</valHgt>
            <codeHgtAccuracy>N</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>80</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>462c8d00-981a-0995-09aa-4ba39161bb41</codeGroupId>
            <txtGroupName>MIRMANDE EOLIENNES</txtGroupName>
          </Obs>
        END
      end
    end
  end

  describe "linked group" do
    subject do
      AIXM.obstacle_group(name: "Mirmande éoliennes")
    end

    describe :add_obstacle do
      it "adds an obstacle to the group and links it to previous" do
        subject.add_obstacle(AIXM::Factory.obstacle)
        subject.add_obstacle(AIXM::Factory.obstacle, linked_to: :previous, link_type: :cable)
        subject.obstacles.count.must_equal 2
        subject.obstacles.last.linked_to.must_equal subject.obstacles.first
        subject.obstacles.last.link_type.must_equal :cable
      end

      it "adds an obstacle to the group and links it to another obstacle" do
        subject.add_obstacle(AIXM::Factory.obstacle)
        subject.add_obstacle(AIXM::Factory.obstacle, linked_to: subject.obstacles.first, link_type: :solid)
        subject.obstacles.count.must_equal 2
        subject.obstacles.last.linked_to.must_equal subject.obstacles.first
        subject.obstacles.last.link_type.must_equal :solid
      end
    end

    describe :to_xml do
      subject do
        AIXM::Factory.linked_obstacle_group
      end

      it "builds correct AIXM" do
        AIXM.aixm!
        subject.to_xml.must_equal <<~END
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
        subject.to_xml.must_equal <<~END
          <!-- Obstacle: [mast] 52.29639722N 002.10675278W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>52.29639722N</geoLat>
              <geoLong>002.10675278W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>18e65683-798d-0941-8de4-cb65a6427035</codeGroupId>
            <txtGroupName>DROITWICH LONGWAVE ANTENNA</txtGroupName>
          </Obs>
          <!-- Obstacle: [mast] 52.29457778N 002.10568611W DROITWICH LW NORTH -->
          <Obs>
            <ObsUid>
              <geoLat>52.29457778N</geoLat>
              <geoLong>002.10568611W</geoLong>
            </ObsUid>
            <txtName>DROITWICH LW NORTH</txtName>
            <codeType>MAST</codeType>
            <codeLgt>N</codeLgt>
            <codeMarking>N</codeMarking>
            <codeDatum>WGE</codeDatum>
            <valGeoAccuracy>0</valGeoAccuracy>
            <uomGeoAccuracy>M</uomGeoAccuracy>
            <valElev>848</valElev>
            <valElevAccuracy>0</valElevAccuracy>
            <valHgt>700</valHgt>
            <codeHgtAccuracy>Y</codeHgtAccuracy>
            <uomDistVer>FT</uomDistVer>
            <valRadius>200</valRadius>
            <uomRadius>M</uomRadius>
            <codeGroupId>18e65683-798d-0941-8de4-cb65a6427035</codeGroupId>
            <txtGroupName>DROITWICH LONGWAVE ANTENNA</txtGroupName>
            <ObsUidLink>
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
