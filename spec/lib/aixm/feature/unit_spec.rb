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
          <UniUid region="LF">
            <txtName>PUJAUT</txtName>
            <codeType>TWR</codeType>
          </UniUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <AhpUid region="LF">
            <codeId>LFNT</codeId>
          </AhpUid>
          <codeClass>ICAO</codeClass>
          <txtRmk>FR only</txtRmk>
        </Uni>
        <!-- Service: AFIS by PUJAUT TWR -->
        <Ser source="LF|GEN|0.0 FACTORY|0|0">
          <SerUid>
            <UniUid region="LF">
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
              <UniUid region="LF">
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
            <UniUid region="LF">
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
              <UniUid region="LF">
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
            <UniUid region="LF">
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
              <UniUid region="LF">
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
          <UniUid region="LF">
            <txtName>PUJAUT</txtName>
            <codeType>TWR</codeType>
          </UniUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeClass>ICAO</codeClass>
        </Uni>
      END
    end

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid = true
      _(subject.to_xml).must_match /<UniUid [^>]*? mid="43032450-13e4-6f1a-728b-8ba8b5d31c92"/x
      _(subject.to_xml).must_match /<SerUid [^>]*? mid="6fcb48c9-10a7-db3a-68c2-405a9dfbcd30"/x
      _(subject.to_xml).must_match /<FqyUid [^>]*? mid="30a9231c-9307-e4c4-5ddd-01315a3c0d42"/x
    end
  end
end
