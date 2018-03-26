require_relative '../../../spec_helper'

describe AIXM::Feature::Airspace do

  context "only required attributes set" do
    subject do
      AIXM.airspace(type: "TMA", name: "Test TMA")
    end

    describe :initialize do
      it "sets defaults" do
        subject.id.must_equal 'E2695A2B'
        subject.layers.must_equal []
        subject.geometry.must_be_instance_of AIXM::Component::Geometry
      end
    end

    describe :id= do
      it "fails on invalid values" do
        -> { subject.id = 123 }.must_raise ArgumentError
      end

      it "upcases value" do
        subject.tap { |s| s.id = 'löl' }.id.must_equal 'LOEL'
      end
    end

    describe :type= do
      it "fails on invalid values" do
        -> { subject.id = 123 }.must_raise ArgumentError
      end

      it "upcases and transcodes value" do
        subject.tap { |s| s.type = 'tma' }.type.must_equal 'TMA'
      end
    end

    describe :name= do
      it "fails on invalid values" do
        -> { subject.name = 123 }.must_raise ArgumentError
      end

      it "upcases value" do
        subject.tap { |s| s.name = 'löl' }.name.must_equal 'LOEL'
      end
    end

    describe :short_name= do
      it "fails on invalid values" do
        -> { subject.short_name = 123 }.must_raise ArgumentError
      end

      it "accepts nil value" do
        subject.tap { |s| s.short_name = nil }.short_name.must_be :nil?
      end

      it "upcases value" do
        subject.tap { |s| s.short_name = 'löl' }.short_name.must_equal 'LOEL'
      end
    end

    describe :to_uid do
      it "must build with arbitrary tag" do
        subject.to_uid.must_match(/<AseUid>/)
        subject.to_uid(as: :FooBar).must_match(/<FooBar>/)
      end
    end

    describe :to_xml do
      it "fails to build AIXM since geometry is not closed" do
        error = -> { subject.to_xml }.must_raise RuntimeError
        error.message.must_equal "geometry not closed"
      end

      it "fails to build AIXM since layers are not defined" do
        subject.geometry = AIXM::Factory.circle_geometry
        error = -> { subject.to_xml }.must_raise RuntimeError
        error.message.must_equal "no layers defined"
      end
    end
  end

  context "only required attributes, geometry and layers set" do
    subject do
      AIXM.airspace(type: "TMA", name: "Test TMA").tap do |airspace|
        airspace.geometry = AIXM::Factory.circle_geometry
        airspace.layers << AIXM::Factory.layer
      end
    end

    describe :to_xml do
      it "builds correct AIXM without id" do
        AIXM.aixm!
        subject.to_xml.must_match(%r{<codeId>E2695A2B</codeId>})
      end

      it "builds correct AIXM without short name" do
        AIXM.aixm!
        subject.to_xml.wont_match(/<txtLocalType>/)
      end

      it "builds correct AIXM with identical name and short name" do
        AIXM.aixm!
        subject.to_xml.wont_match(/<txtLocalType>/)
      end
    end
  end

  context "with one layer" do
    subject do
      AIXM::Factory.polygon_airspace
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~"END"
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase>
            <AseUid>
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <codeSelAvbl>Y</codeSelAvbl>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid>
                <codeType>D</codeType>
                <codeId>PA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.90416667N</geoLatArc>
              <geoLongArc>007.56333333E</geoLongArc>
            </Avx>
            <Avx>
              <GbrUid>
                <txtName>FRANCE_GERMANY</txtName>
              </GbrUid>
              <codeType>FNT</codeType>
              <geoLat>47.94361111N</geoLat>
              <geoLong>007.59583333E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
        END
      end
    end
  end

  context "with two layers" do
    subject do
      AIXM::Factory.polygon_airspace.tap do |airspace|
        airspace.layers << AIXM::Factory.layer
      end
    end

    describe :to_xml do
      it "must build correct OFMX" do
        AIXM.ofmx!
        subject.to_xml.must_equal <<~"END"
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase classLayers="2">
            <AseUid>
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
          </Ase>
          <Abd>
            <AbdUid>
              <AseUid>
                <codeType>D</codeType>
                <codeId>PA</codeId>
              </AseUid>
            </AbdUid>
            <Avx>
              <codeType>CWA</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
              <geoLatArc>47.90416667N</geoLatArc>
              <geoLongArc>007.56333333E</geoLongArc>
            </Avx>
            <Avx>
              <GbrUid>
                <txtName>FRANCE_GERMANY</txtName>
              </GbrUid>
              <codeType>FNT</codeType>
              <geoLat>47.94361111N</geoLat>
              <geoLong>007.59583333E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
            <Avx>
              <codeType>GRC</codeType>
              <geoLat>47.85916667N</geoLat>
              <geoLong>007.56000000E</geoLong>
              <codeDatum>WGE</codeDatum>
            </Avx>
          </Abd>
          <Ase>
            <AseUid>
              <codeType>CLASS</codeType>
              <codeId>E5B59824</codeId>
            </AseUid>
            <txtName>POLYGON AIRSPACE LAYER 1</txtName>
            <codeClass>C</codeClass>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <codeSelAvbl>Y</codeSelAvbl>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Adg>
            <AdgUid>
              <AseUid>
                <codeType>CLASS</codeType>
                <codeId>E5B59824</codeId>
              </AseUid>
            </AdgUid>
            <AseUidSameExtent>
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUidSameExtent>
          </Adg>
          <Ase>
            <AseUid>
              <codeType>CLASS</codeType>
              <codeId>75DA71AE</codeId>
            </AseUid>
            <txtName>POLYGON AIRSPACE LAYER 2</txtName>
            <codeClass>C</codeClass>
            <codeDistVerUpper>STD</codeDistVerUpper>
            <valDistVerUpper>65</valDistVerUpper>
            <uomDistVerUpper>FL</uomDistVerUpper>
            <codeDistVerLower>STD</codeDistVerLower>
            <valDistVerLower>45</valDistVerLower>
            <uomDistVerLower>FL</uomDistVerLower>
            <codeDistVerMax>ALT</codeDistVerMax>
            <valDistVerMax>6000</valDistVerMax>
            <uomDistVerMax>FT</uomDistVerMax>
            <codeDistVerMnm>HEI</codeDistVerMnm>
            <valDistVerMnm>3000</valDistVerMnm>
            <uomDistVerMnm>FT</uomDistVerMnm>
            <Att>
              <codeWorkHr>H24</codeWorkHr>
            </Att>
            <codeSelAvbl>Y</codeSelAvbl>
            <txtRmk>airspace layer</txtRmk>
          </Ase>
          <Adg>
            <AdgUid>
              <AseUid>
                <codeType>CLASS</codeType>
                <codeId>75DA71AE</codeId>
              </AseUid>
            </AdgUid>
            <AseUidSameExtent>
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUidSameExtent>
          </Adg>
        END
      end
    end
  end

end
