require_relative '../../../spec_helper'

describe AIXM::Feature::Obstacle do
  subject do
    AIXM::Factory.obstacle
  end

  describe :initialize do
    it "sets defaults" do
      subject = AIXM.obstacle(
        type: :tower,
        xy: AIXM.xy(lat: %q(48°51'29.7"N), long: %q(002°17'40.52"E)),
        radius: AIXM.d(88, :m),
        z: AIXM.z(1187 , :qnh)
      )
      _(subject).wont_be :lighting
      _(subject).wont_be :marking
      _(subject).wont_be :height_accurate
    end
  end

  describe :name= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { |s| s.name = 'Teufelsbrücke' }.name).must_equal 'TEUFELSBRUECKE'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _([nil, :foobar]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.type = :WINDTURBINE }.type).must_equal :wind_turbine
      _(subject.tap { |s| s.type = :TOWER }.type).must_equal :tower
    end
  end

  describe :xy= do
    macro :xy

    it "fails on nil values" do
      _([nil]).wont_be_written_to subject, :xy
    end
  end

  describe :radius= do
    it "fails on invalid values" do
      _([:foobar, 123, AIXM.d(0, :m)]).wont_be_written_to subject, :radius
    end

    it "accepts valid values" do
      _([AIXM::Factory.d, nil]).must_be_written_to subject, :radius
    end
  end

  describe :z= do
    macro :z_qnh

    it "fails on nil values" do
      _([nil]).wont_be_written_to subject, :z
    end
  end

  describe :lighting= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :lighting
    end

    it "accepts valid values" do
      _([true, false, nil]).must_be_written_to subject, :lighting
    end
  end

  describe :lighting_remarks= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :lighting_remarks
    end

    it "stringifies valid values" do
      _(subject.tap { |s| s.lighting_remarks = 'foobar' }.lighting_remarks).must_equal 'foobar'
      _(subject.tap { |s| s.lighting_remarks = 123 }.lighting_remarks).must_equal '123'
    end
  end

  describe :marking= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :marking
    end

    it "accepts valid values" do
      _([true, false, nil]).must_be_written_to subject, :marking
    end
  end

  describe :marking_remarks= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :marking_remarks
    end

    it "stringifies valid values" do
      _(subject.tap { |s| s.marking_remarks = 'foobar' }.marking_remarks).must_equal 'foobar'
      _(subject.tap { |s| s.marking_remarks = 123 }.marking_remarks).must_equal '123'
    end
  end

  describe :height= do
    it "fails on invalid values" do
      _([:foobar, 123, AIXM.d(0, :m)]).wont_be_written_to subject, :height
    end

    it "accepts valid values" do
      _([nil, AIXM::Factory.d]).must_be_written_to subject, :height
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

  describe :height_accurate= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :height_accurate
    end

    it "accepts valid values" do
      _([true, false, nil]).must_be_written_to subject, :height_accurate
    end
  end

  describe :valid_from= do
    it "fails on invalid values" do
      _(['foobar', '2018-01-77']).wont_be_written_to subject, :valid_from
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :valid_from
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      _(subject.tap { |s| s.valid_from = string }.valid_from).must_equal Time.parse(string)
    end
  end

  describe :valid_until= do
    it "fails on invalid values" do
      _(['foobar', '2018-01-77']).wont_be_written_to subject, :valid_until
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :valid_until
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      _(subject.tap { |s| s.valid_until = string }.valid_until).must_equal Time.parse(string)
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :grouped? do
    it "returns false since single obstacles are not grouped" do
      _(subject).wont_be :grouped?
    end
  end

  describe :linked? do
    subject do
      AIXM::Factory.unlinked_obstacle_group.obstacles.first
    end

    it "returns false for unlinked obstacles" do
      _(subject).wont_be :linked?
    end

    it "returns true for linked obstacles" do
      subject = AIXM::Factory.linked_obstacle_group.obstacles.last
      _(subject).must_be :linked?
    end
  end

  describe :to_xml do
    macro :mid

    it "builds correct AIXM" do
      _(subject.to_xml).must_equal <<~END
        <!-- Obstacle: [tower] 48.85825000N 002.29458889E EIFFEL TOWER -->
        <Obs>
          <ObsUid>
            <geoLat>485129.70N</geoLat>
            <geoLong>0021740.52E</geoLong>
          </ObsUid>
          <txtName>EIFFEL TOWER</txtName>
          <txtDescrType>TOWER</txtDescrType>
          <codeGroup>N</codeGroup>
          <codeLgt>Y</codeLgt>
          <txtDescrLgt>red strobes</txtDescrLgt>
          <codeDatum>WGE</codeDatum>
          <valGeoAccuracy>2</valGeoAccuracy>
          <uomGeoAccuracy>M</uomGeoAccuracy>
          <valElev>1187</valElev>
          <valElevAccuracy>3</valElevAccuracy>
          <valHgt>1063</valHgt>
          <uomDistVer>FT</uomDistVer>
          <txtRmk>Temporary light installations (white strobes, gyro light etc)</txtRmk>
        </Obs>
      END
    end

    it "builds correct OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- Obstacle group: EIFFEL TOWER -->
        <Ogr>
          <OgrUid>
            <txtName>EIFFEL TOWER</txtName>
            <geoLat>48.85825000N</geoLat>
            <geoLong>002.29458889E</geoLong>
          </OgrUid>
          <codeDatum>WGE</codeDatum>
          <valGeoAccuracy>2</valGeoAccuracy>
          <uomGeoAccuracy>M</uomGeoAccuracy>
          <valElevAccuracy>3</valElevAccuracy>
          <uomElevAccuracy>FT</uomElevAccuracy>
        </Ogr>
        <!-- Obstacle: [tower] 48.85825000N 002.29458889E EIFFEL TOWER -->
        <Obs>
          <ObsUid>
            <OgrUid>
              <txtName>EIFFEL TOWER</txtName>
              <geoLat>48.85825000N</geoLat>
              <geoLong>002.29458889E</geoLong>
            </OgrUid>
            <geoLat>48.85825000N</geoLat>
            <geoLong>002.29458889E</geoLong>
          </ObsUid>
          <txtName>EIFFEL TOWER</txtName>
          <codeType>TOWER</codeType>
          <codeGroup>N</codeGroup>
          <codeLgt>Y</codeLgt>
          <txtDescrLgt>red strobes</txtDescrLgt>
          <codeDatum>WGE</codeDatum>
          <valElev>1187</valElev>
          <valHgt>1063</valHgt>
          <uomDistVer>FT</uomDistVer>
          <codeHgtAccuracy>Y</codeHgtAccuracy>
          <valRadius>88</valRadius>
          <uomRadius>M</uomRadius>
          <datetimeValidWef>2018-01-01T12:00:00+01:00</datetimeValidWef>
          <datetimeValidTil>2019-01-01T12:00:00+01:00</datetimeValidTil>
          <txtRmk>Temporary light installations (white strobes, gyro light etc)</txtRmk>
        </Obs>
      END
    end

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid = true
      AIXM.config.region = 'LF'
      _(subject.to_xml).must_match /<ObsUid mid="864b252b-0b1d-66c4-22cd-14dbda287467">/
    end
  end
end
