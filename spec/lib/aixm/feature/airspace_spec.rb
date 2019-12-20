require_relative '../../../spec_helper'

describe AIXM::Feature::Airspace do

  context "only required attributes set" do
    subject do
      AIXM.airspace(type: "TMA", name: "Test TMA")
    end

    describe :initialize do
      it "sets defaults" do
        _(subject.id).must_equal 'C55466EC'
        _(subject.geometry).must_be_instance_of AIXM::Component::Geometry
      end
    end

    describe :id= do
      it "fails on invalid values" do
        _([:foobar, 123]).wont_be_written_to subject, :id
      end

      it "falls back to id derived from digest of type, local_type and name" do
        _(subject.tap { |s| s.id = nil }.id).must_equal 'C55466EC'
      end

      it "upcases value" do
        _(subject.tap { |s| s.id = 'löl' }.id).must_equal 'LOEL'
      end
    end

    describe :type= do
      it "fails on invalid values" do
        _([nil, :foobar, 123]).wont_be_written_to subject, :type
      end

      it "looks up valid values" do
        _(subject.tap { |s| s.type = :danger_area }.type).must_equal :danger_area
        _(subject.tap { |s| s.type = :P }.type).must_equal :prohibited_area
      end
    end

    describe :local_type= do
      it "fails on invalid values" do
        _([:foobar, 123]).wont_be_written_to subject, :local_type
      end

      it "accepts nil value" do
        _([nil]).must_be_written_to subject, :local_type
      end

      it "upcases value" do
        _(subject.tap { |s| s.local_type = 'löl' }.local_type).must_equal 'LOEL'
      end
    end

    describe :name= do
      it "fails on invalid values" do
        _([:foobar, 123]).wont_be_written_to subject, :name
      end

      it "accepts nil value" do
        _([nil]).must_be_written_to subject, :name
      end

      it "upcases value" do
        _(subject.tap { |s| s.name = 'löl' }.name).must_equal 'LOEL'
      end
    end

    describe :to_uid do
      it "builds with arbitrary tag" do
        _(subject.to_uid).must_match(/<AseUid>/)
        _(subject.to_uid(as: :FooBar)).must_match(/<FooBar>/)
      end
    end

    describe :to_xml do
      it "fails to build AIXM since geometry is not closed" do
        subject.add_layer(AIXM::Factory.layer)
        _{ subject.to_xml }.must_raise AIXM::GeometryError
      end

      it "fails to build AIXM since layers are not defined" do
        subject.geometry = AIXM::Factory.circle_geometry
        _{ subject.to_xml }.must_raise AIXM::LayerError
      end
    end
  end

  context "only required attributes, geometry and layers set" do
    subject do
      AIXM.airspace(type: "TMA", name: "Test TMA").tap do |airspace|
        airspace.geometry = AIXM::Factory.circle_geometry
        airspace.add_layer(AIXM::Factory.layer)
      end
    end

    describe :to_xml do
      macro :mid

      it "builds correct AIXM without id" do
        _(subject.to_xml).must_match(%r{<codeId>C55466EC</codeId>})
      end

      it "builds correct AIXM without short name" do
        _(subject.to_xml).wont_match(/<txtLocalType>/)
      end

      it "builds correct AIXM with identical name and short name" do
        _(subject.to_xml).wont_match(/<txtLocalType>/)
      end
    end
  end

  context "with one layer" do
    subject do
      AIXM::Factory.polygon_airspace
    end

    describe :to_xml do
      macro :mid

      it "builds correct complete OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~"END"
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
            <AseUid>
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUid>
            <txtLocalType>POLYGON</txtLocalType>
            <txtName>POLYGON AIRSPACE</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
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

      it "builds correct minimal OFMX" do
        AIXM.ofmx!
        subject.local_type = subject.name = nil
        _(subject.to_xml).must_equal <<~"END"
          <!-- Airspace: [D] UNNAMED -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
            <AseUid>
              <codeType>D</codeType>
              <codeId>PA</codeId>
            </AseUid>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
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

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid = true
      AIXM.config.region = 'LF'
      _(subject.to_xml).must_match /<AseUid mid="8894c821-b486-8128-48f2-a47c2e9f4c13">/
#      _(subject.to_xml).must_match /<AbdUid mid="">/
    end
  end

  context "with two layers" do
    subject do
      AIXM::Factory.polygon_airspace.tap do |airspace|
        airspace.add_layer(AIXM::Factory.layer)
      end
    end

    describe :to_xml do
      macro :mid

      it "builds correct OFMX" do
        AIXM.ofmx!
        _(subject.to_xml).must_equal <<~"END"
          <!-- Airspace: [D] POLYGON AIRSPACE -->
          <Ase source="LF|GEN|0.0 FACTORY|0|0">
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
              <codeId>B794588D</codeId>
            </AseUid>
            <txtName>POLYGON AIRSPACE LAYER 1</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
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
                <codeId>B794588D</codeId>
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
              <codeId>64589EAF</codeId>
            </AseUid>
            <txtName>POLYGON AIRSPACE LAYER 2</txtName>
            <codeClass>C</codeClass>
            <codeLocInd>XXXX</codeLocInd>
            <codeActivity>TFC-AD</codeActivity>
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
                <codeId>64589EAF</codeId>
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
