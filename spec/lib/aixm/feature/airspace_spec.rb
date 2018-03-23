require_relative '../../../spec_helper'

describe AIXM::Feature::Airspace do

  context "with one class layer" do
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
            <codeSelAvbl>false</codeSelAvbl>
            <txtRmk>polygon airspace</txtRmk>
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

  context "with two class layers" do
    subject do
      AIXM::Factory.polygon_airspace.tap do |airspace|
        airspace.class_layers << AIXM::Factory.class_layer
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
              <codeId>1ECFC489</codeId>
            </AseUid>
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
          </Ase>
          <Adg>
            <AdgUid>
              <AseUid>
                <codeType>CLASS</codeType>
                <codeId>1ECFC489</codeId>
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
              <codeId>7C6BF0F1</codeId>
            </AseUid>
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
          </Ase>
          <Adg>
            <AdgUid>
              <AseUid>
                <codeType>CLASS</codeType>
                <codeId>7C6BF0F1</codeId>
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

  context "partially incomplete" do
    subject do
      AIXM::Factory.polygon_airspace
    end

    it "must build correct AIXM without id" do
      subject.id = nil
      AIXM.aixm!
      subject.to_xml.must_match(%r{<codeId>0938BE24</codeId>})
    end

    it "must build correct AIXM without short name" do
      subject.short_name = nil
      AIXM.aixm!
      subject.to_xml.wont_match(/txtLocalType/)
    end

    it "must build correct AIXM with identical name and short name" do
      subject.short_name = 'POLYGON AIRSPACE'
      AIXM.aixm!
      subject.to_xml.wont_match(/txtLocalType/)
    end

    it "must build correct AIXM without schedule" do
      subject.schedule = nil
      AIXM.aixm!
      subject.to_xml.wont_match(/codeWorkHr/)
    end
  end
end
