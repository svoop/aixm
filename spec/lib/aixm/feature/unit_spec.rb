require_relative '../../../spec_helper'

describe AIXM::Feature::Unit do
  subject do
    AIXM::Factory.unit
  end

  describe :organisation= do
    macro :organisation

    it "fails on nil value" do
      [nil].wont_be_written_to subject, :organisation
    end
  end

  describe :name= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'Nîmes-Alès APP' }.name.must_equal 'NIMES-ALES APP'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      subject.tap { |s| s.type = :flight_information_centre }.type.must_equal :flight_information_centre
      subject.tap { |s| s.type = :MET }.type.must_equal :meteorological_office
    end
  end

  describe :class= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :class
    end

    it "looks up valid values" do
      subject.tap { |s| s.class = :icao }.class.must_equal :icao
      subject.tap { |s| s.class = :OTHER }.class.must_equal :other
    end
  end

  describe :airport= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :airport
    end

    it "accepts valid values" do
      [nil, AIXM::Factory.airport].must_be_written_to subject, :airport
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
      subject.to_xml.must_equal <<~END
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
        <Ser>
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
        <Ser>
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
        <Ser>
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
      subject.to_xml.must_equal <<~END
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
  end
end
