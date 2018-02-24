require_relative '../../../spec_helper'

describe AIXM::Feature::Airspace do
  context "incomplete" do
    subject do
      AIXM.airspace(name: 'foobar', type: 'D')
    end

    describe :complete? do
      it "must fail validation" do
        subject.wont_be :complete?
      end
    end
  end

  context "complete" do
    context "with one class layer" do
      subject do
        AIXM::Factory.polygon_airspace
      end

      describe :complete? do
        it "must pass validation" do
          subject.must_be :complete?
        end
      end

      describe :to_digest do
        it "must return digest of payload" do
          subject.to_digest.must_equal 595551355
        end
      end

      describe :to_xml do
        it "must build correct OFMX" do
          AIXM.ofmx!
          digest = subject.to_digest
          subject.to_xml.must_equal <<~"END"
            <!-- Airspace: [D] POLYGON AIRSPACE -->
            <Ase xt_classLayersAvail="false">
              <AseUid mid="#{digest}" newEntity="true">
                <codeType>D</codeType>
                <codeId>#{digest}</codeId>
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
              <txtRmk>polygon airspace</txtRmk>
              <xt_selAvail>false</xt_selAvail>
            </Ase>
            <Abd>
              <AbdUid>
                <AseUid mid="#{digest}" newEntity="true">
                  <codeType>D</codeType>
                  <codeId>#{digest}</codeId>
                </AseUid>
              </AbdUid>
              <Avx>
                <codeType>CWA</codeType>
                <geoLat>47.85916667N</geoLat>
                <geoLong>7.56000000E</geoLong>
                <codeDatum>WGE</codeDatum>
                <geoLatArc>47.90416667N</geoLatArc>
                <geoLongArc>7.56333333E</geoLongArc>
              </Avx>
              <Avx>
                <codeType>FNT</codeType>
                <geoLat>47.94361111N</geoLat>
                <geoLong>7.59583333E</geoLong>
                <codeDatum>WGE</codeDatum>
                <GbrUid>
                  <txtName>FRANCE_GERMANY</txtName>
                </GbrUid>
              </Avx>
              <Avx>
                <codeType>GRC</codeType>
                <geoLat>47.85916667N</geoLat>
                <geoLong>7.56000000E</geoLong>
                <codeDatum>WGE</codeDatum>
              </Avx>
            </Abd>
          END
        end
      end

      context "with two class layers" do
        subject do
          AIXM::Factory.polygon_airspace.tap do |airspace|
            airspace.class_layers << AIXM::Factory.class_layer
          end
        end

        describe :complete? do
          it "must pass validation" do
            subject.must_be :complete?
          end
        end

        describe :to_digest do
          it "must return digest of payload" do
            subject.to_digest.must_equal 633292197
          end
        end

        describe :to_xml do
          it "must build correct OFMX" do
            AIXM.ofmx!
            digest = subject.to_digest
            subject.to_xml.must_equal <<~"END"
              <!-- Airspace: [D] POLYGON AIRSPACE -->
              <Ase xt_classLayersAvail="true">
                <AseUid mid="#{digest}" newEntity="true">
                  <codeType>D</codeType>
                  <codeId>#{digest}</codeId>
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
                <txtRmk>polygon airspace</txtRmk>
                <xt_selAvail>false</xt_selAvail>
              </Ase>
              <Abd>
                <AbdUid>
                  <AseUid mid="#{digest}" newEntity="true">
                    <codeType>D</codeType>
                    <codeId>#{digest}</codeId>
                  </AseUid>
                </AbdUid>
                <Avx>
                  <codeType>CWA</codeType>
                  <geoLat>47.85916667N</geoLat>
                  <geoLong>7.56000000E</geoLong>
                  <codeDatum>WGE</codeDatum>
                  <geoLatArc>47.90416667N</geoLatArc>
                  <geoLongArc>7.56333333E</geoLongArc>
                </Avx>
                <Avx>
                  <codeType>FNT</codeType>
                  <geoLat>47.94361111N</geoLat>
                  <geoLong>7.59583333E</geoLong>
                  <codeDatum>WGE</codeDatum>
                  <GbrUid>
                    <txtName>FRANCE_GERMANY</txtName>
                  </GbrUid>
                </Avx>
                <Avx>
                  <codeType>GRC</codeType>
                  <geoLat>47.85916667N</geoLat>
                  <geoLong>7.56000000E</geoLong>
                  <codeDatum>WGE</codeDatum>
                </Avx>
              </Abd>
              <Adg>
                <AdgUid>
                  <AseUid mid="#{digest}.1">
                    <codeType>CLASS</codeType>
                  </AseUid>
                </AdgUid>
                <AdgUid>
                  <AseUid mid="#{digest}.2">
                    <codeType>CLASS</codeType>
                  </AseUid>
                </AdgUid>
                <AseUidSameExtent mid="#{digest}"/>
              </Adg>
              <Ase>
                <AseUid mid="#{digest}.1">
                  <codeType>CLASS</codeType>
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
              <Ase>
                <AseUid mid="#{digest}.2">
                  <codeType>CLASS</codeType>
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
            END
          end
        end
      end
    end

    context "partially complete" do
      subject do
        AIXM::Factory.polygon_airspace
      end

      it "must build correct XML without short name" do
        subject.short_name = nil
        subject.to_xml.wont_match(/txtLocalType/)
      end

      it "must build correct XML with identical name and short name" do
        subject.short_name = 'POLYGON AIRSPACE'
        subject.to_xml.wont_match(/txtLocalType/)
      end

      it "must build correct XML without schedule" do
        subject.schedule = nil
        subject.to_xml.wont_match(/codeWorkHr/)
      end
    end
  end
end
