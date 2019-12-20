require_relative '../../../spec_helper'

describe AIXM::Feature::Unit do
  subject do
    AIXM::Factory.unit
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { |s| s.name = 'Nîmes-Alès APP' }.name).must_equal 'NIMES-ALES APP'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.type = :flight_information_centre }.type).must_equal :flight_information_centre
      _(subject.tap { |s| s.type = :MET }.type).must_equal :meteorological_office
    end
  end

  describe :class= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :class
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.class = :icao }.class).must_equal :icao
      _(subject.tap { |s| s.class = :OTHER }.class).must_equal :other
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :name_with_type do
    it "concats the name and the type" do
      _(subject.send(:name_with_type)).must_equal 'PUJAUT TWR'
    end
  end

  describe :to_xml do
    let :service do
      AIXM::Factory.service.tap do |service|
        service.type = :AFIS
      end
    end

    it "populates the mid attribute" do
      _(subject.mid).must_be :nil?
      _(subject.services.first.mid).must_be :nil?
      _(subject.services.first.frequencies.first.mid).must_be :nil?
      subject.to_xml
      _(subject.mid).wont_be :nil?
      _(subject.services.first.mid).wont_be :nil?
      _(subject.services.first.frequencies.first.mid).wont_be :nil?
    end

    it "builds correct complete AIXM" do
      2.times { subject.add_service(service) }
      AIXM.aixm!
      _(subject.to_xml).must_equal <<~END
        <!-- Unit: PUJAUT TWR -->
        <Uni>
          <UniUid>
            <txtName>PUJAUT</txtName>
          </UniUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <AhpUid>
            <codeId>LFNT</codeId>
          </AhpUid>
          <codeType>TWR</codeType>
          <codeClass>ICAO</codeClass>
          <txtRmk>FR only</txtRmk>
        </Uni>
        <!-- Service: AFIS by PUJAUT TWR -->
        <Ser>
          <SerUid>
            <UniUid>
              <txtName>PUJAUT</txtName>
            </UniUid>
            <codeType>AFIS</codeType>
            <noSeq>1</noSeq>
          </SerUid>
          <Stt>
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <txtRmk>service remarks</txtRmk>
        </Ser>
        <Fqy>
          <FqyUid>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT</txtName>
              </UniUid>
              <codeType>AFIS</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <valFreqTrans>123.35</valFreqTrans>
          </FqyUid>
          <valFreqRec>124.1</valFreqRec>
          <uomFreq>MHZ</uomFreq>
          <Ftt>
            <codeWorkHr>H24</codeWorkHr>
          </Ftt>
          <txtRmk>frequency remarks</txtRmk>
          <Cdl>
            <txtCallSign>PUJAUT CONTROL</txtCallSign>
            <codeLang>EN</codeLang>
          </Cdl>
          <Cdl>
            <txtCallSign>PUJAUT CONTROLE</txtCallSign>
            <codeLang>FR</codeLang>
          </Cdl>
        </Fqy>
        <!-- Service: AFIS by PUJAUT TWR -->
        <Ser>
          <SerUid>
            <UniUid>
              <txtName>PUJAUT</txtName>
            </UniUid>
            <codeType>AFIS</codeType>
            <noSeq>2</noSeq>
          </SerUid>
          <Stt>
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <txtRmk>service remarks</txtRmk>
        </Ser>
        <Fqy>
          <FqyUid>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT</txtName>
              </UniUid>
              <codeType>AFIS</codeType>
              <noSeq>2</noSeq>
            </SerUid>
            <valFreqTrans>123.35</valFreqTrans>
          </FqyUid>
          <valFreqRec>124.1</valFreqRec>
          <uomFreq>MHZ</uomFreq>
          <Ftt>
            <codeWorkHr>H24</codeWorkHr>
          </Ftt>
          <txtRmk>frequency remarks</txtRmk>
          <Cdl>
            <txtCallSign>PUJAUT CONTROL</txtCallSign>
            <codeLang>EN</codeLang>
          </Cdl>
          <Cdl>
            <txtCallSign>PUJAUT CONTROLE</txtCallSign>
            <codeLang>FR</codeLang>
          </Cdl>
        </Fqy>
        <!-- Service: APP by PUJAUT TWR -->
        <Ser>
          <SerUid>
            <UniUid>
              <txtName>PUJAUT</txtName>
            </UniUid>
            <codeType>APP</codeType>
            <noSeq>1</noSeq>
          </SerUid>
          <Stt>
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <txtRmk>service remarks</txtRmk>
        </Ser>
        <Fqy>
          <FqyUid>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT</txtName>
              </UniUid>
              <codeType>APP</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <valFreqTrans>123.35</valFreqTrans>
          </FqyUid>
          <valFreqRec>124.1</valFreqRec>
          <uomFreq>MHZ</uomFreq>
          <Ftt>
            <codeWorkHr>H24</codeWorkHr>
          </Ftt>
          <txtRmk>frequency remarks</txtRmk>
          <Cdl>
            <txtCallSign>PUJAUT CONTROL</txtCallSign>
            <codeLang>EN</codeLang>
          </Cdl>
          <Cdl>
            <txtCallSign>PUJAUT CONTROLE</txtCallSign>
            <codeLang>FR</codeLang>
          </Cdl>
        </Fqy>
      END
    end

    it "builds correct complete OFMX" do
      2.times { subject.add_service(service) }
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- Unit: PUJAUT TWR -->
        <Uni source="LF|GEN|0.0 FACTORY|0|0">
          <UniUid>
            <txtName>PUJAUT</txtName>
            <codeType>TWR</codeType>
          </UniUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <AhpUid>
            <codeId>LFNT</codeId>
          </AhpUid>
          <codeClass>ICAO</codeClass>
          <txtRmk>FR only</txtRmk>
        </Uni>
        <!-- Service: AFIS by PUJAUT TWR -->
        <Ser source="LF|GEN|0.0 FACTORY|0|0">
          <SerUid>
            <UniUid>
              <txtName>PUJAUT</txtName>
              <codeType>TWR</codeType>
            </UniUid>
            <codeType>AFIS</codeType>
            <noSeq>1</noSeq>
          </SerUid>
          <Stt>
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <txtRmk>service remarks</txtRmk>
        </Ser>
        <Fqy>
          <FqyUid>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT</txtName>
                <codeType>TWR</codeType>
              </UniUid>
              <codeType>AFIS</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <valFreqTrans>123.35</valFreqTrans>
          </FqyUid>
          <valFreqRec>124.1</valFreqRec>
          <uomFreq>MHZ</uomFreq>
          <Ftt>
            <codeWorkHr>H24</codeWorkHr>
          </Ftt>
          <txtRmk>frequency remarks</txtRmk>
          <Cdl>
            <txtCallSign>PUJAUT CONTROL</txtCallSign>
            <codeLang>EN</codeLang>
          </Cdl>
          <Cdl>
            <txtCallSign>PUJAUT CONTROLE</txtCallSign>
            <codeLang>FR</codeLang>
          </Cdl>
        </Fqy>
        <!-- Service: AFIS by PUJAUT TWR -->
        <Ser source="LF|GEN|0.0 FACTORY|0|0">
          <SerUid>
            <UniUid>
              <txtName>PUJAUT</txtName>
              <codeType>TWR</codeType>
            </UniUid>
            <codeType>AFIS</codeType>
            <noSeq>2</noSeq>
          </SerUid>
          <Stt>
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <txtRmk>service remarks</txtRmk>
        </Ser>
        <Fqy>
          <FqyUid>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT</txtName>
                <codeType>TWR</codeType>
              </UniUid>
              <codeType>AFIS</codeType>
              <noSeq>2</noSeq>
            </SerUid>
            <valFreqTrans>123.35</valFreqTrans>
          </FqyUid>
          <valFreqRec>124.1</valFreqRec>
          <uomFreq>MHZ</uomFreq>
          <Ftt>
            <codeWorkHr>H24</codeWorkHr>
          </Ftt>
          <txtRmk>frequency remarks</txtRmk>
          <Cdl>
            <txtCallSign>PUJAUT CONTROL</txtCallSign>
            <codeLang>EN</codeLang>
          </Cdl>
          <Cdl>
            <txtCallSign>PUJAUT CONTROLE</txtCallSign>
            <codeLang>FR</codeLang>
          </Cdl>
        </Fqy>
        <!-- Service: APP by PUJAUT TWR -->
        <Ser source="LF|GEN|0.0 FACTORY|0|0">
          <SerUid>
            <UniUid>
              <txtName>PUJAUT</txtName>
              <codeType>TWR</codeType>
            </UniUid>
            <codeType>APP</codeType>
            <noSeq>1</noSeq>
          </SerUid>
          <Stt>
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <txtRmk>service remarks</txtRmk>
        </Ser>
        <Fqy>
          <FqyUid>
            <SerUid>
              <UniUid>
                <txtName>PUJAUT</txtName>
                <codeType>TWR</codeType>
              </UniUid>
              <codeType>APP</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <valFreqTrans>123.35</valFreqTrans>
          </FqyUid>
          <valFreqRec>124.1</valFreqRec>
          <uomFreq>MHZ</uomFreq>
          <Ftt>
            <codeWorkHr>H24</codeWorkHr>
          </Ftt>
          <txtRmk>frequency remarks</txtRmk>
          <Cdl>
            <txtCallSign>PUJAUT CONTROL</txtCallSign>
            <codeLang>EN</codeLang>
          </Cdl>
          <Cdl>
            <txtCallSign>PUJAUT CONTROLE</txtCallSign>
            <codeLang>FR</codeLang>
          </Cdl>
        </Fqy>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.instance_variable_set(:@airport, nil)
      subject.remarks = nil
      subject.instance_variable_set(:'@services', [])
      _(subject.to_xml).must_equal <<~END
        <!-- Unit: PUJAUT TWR -->
        <Uni source="LF|GEN|0.0 FACTORY|0|0">
          <UniUid>
            <txtName>PUJAUT</txtName>
            <codeType>TWR</codeType>
          </UniUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeClass>ICAO</codeClass>
        </Uni>
      END
    end

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid = true
      AIXM.config.region = 'LF'
      _(subject.to_xml).must_match /<UniUid mid="81a07b56-50cc-90af-e45d-d1d69a0b6c27">/
      _(subject.to_xml).must_match /<SerUid mid="02afe8d9-5f61-0e48-26d9-e2d5a1e560cc">/
      _(subject.to_xml).must_match /<FqyUid mid="dc6b09b4-bcd4-e2b1-1a54-c8cf09bfb253">/
    end
  end
end
