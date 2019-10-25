require_relative '../../../spec_helper'

describe AIXM::Feature::Unit do
  subject do
    AIXM::Factory.unit
  end

  describe :organisation= do
    macro :organisation

    it "fails on nil value" do
      _([nil]).wont_be_written_to subject, :organisation
    end
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

  describe :airport= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :airport
    end

    it "accepts valid values" do
      _([nil, AIXM::Factory.airport]).must_be_written_to subject, :airport
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    let :service do
      AIXM::Factory.service.tap do |service|
        service.type = :AFIS
      end
    end

    it "builds correct complete OFMX" do
      2.times { subject.add_service(service) }
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- Unit: PUJAUT TWR -->
        <Uni source="LF|GEN|0.0 FACTORY|0|0">
          <UniUid>
            <txtName>PUJAUT TWR</txtName>
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
        <Ser source="LF|GEN|0.0 FACTORY|0|0">
          <SerUid>
            <UniUid>
              <txtName>PUJAUT TWR</txtName>
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
                <txtName>PUJAUT TWR</txtName>
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
              <txtName>PUJAUT TWR</txtName>
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
                <txtName>PUJAUT TWR</txtName>
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
              <txtName>PUJAUT TWR</txtName>
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
                <txtName>PUJAUT TWR</txtName>
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
      subject.airport = subject.remarks = nil
      subject.instance_variable_set(:'@services', [])
      _(subject.to_xml).must_equal <<~END
        <!-- Unit: PUJAUT TWR -->
        <Uni source="LF|GEN|0.0 FACTORY|0|0">
          <UniUid>
            <txtName>PUJAUT TWR</txtName>
          </UniUid>
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeType>TWR</codeType>
          <codeClass>ICAO</codeClass>
        </Uni>
      END
    end

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid_region = 'LF'
      _(subject.to_xml).must_match /<UniUid mid="92534b75-1c12-edc5-351b-740cb82e87dd">/
      _(subject.to_xml).must_match /<SerUid mid="9240cf80-9cba-7ea5-ae39-6b682305db78">/
      _(subject.to_xml).must_match /<FqyUid mid="48d8e7db-88b1-8e2f-2f27-2c2521e7ac27">/      
    end
  end
end
