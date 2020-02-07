require_relative '../../spec_helper'


describe AIXM::PayloadHash do
  subject do
    <<~END
      <SerUid>
        <UniUid region="LF">
          <txtName>STRASBOURG APP</txtName>
        </UniUid>
        <codeType subversion="1.2" version="1">APP</codeType>
        <noSeq>1</noSeq>
      </SerUid>
    END
  end

  let(:payload_array) { ["SerUid", "UniUid", "region", "LF", "txtName", "STRASBOURG APP", "codeType", "subversion", "1.2", "version", "1", "APP", "noSeq", "1"] }
  let(:payload_hash) { "6201128f-cdc1-59f4-1858-f30bdfc7f0d3" }

  describe :initialize do
    it "accepts XML strings and XML fragments" do
      _(AIXM::PayloadHash.new(subject))
      _(AIXM::PayloadHash.new(Nokogiri::XML.fragment(subject)))
    end

    it "fails on invalid values" do
      _{ AIXM::PayloadHash.new(nil) }.must_raise ArgumentError
      _{ AIXM::PayloadHash.new(123) }.must_raise ArgumentError
    end
  end

  describe :payload_array do
    it "builds correct array of payload attributes and elements" do
      _(AIXM::PayloadHash.new(subject).send(:payload_array)).must_equal payload_array
    end

    it "must ignore mid attributes" do
      alt_subject = subject.sub(/<SerUid>/, '<SerUid mid="123">')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal payload_array
    end

    it "must ignore source attributes" do
      alt_subject = subject.sub(/<SerUid>/, '<SerUid source="123">')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal payload_array
    end

    it "must order the element arguments alphabetically" do
      alt_subject = subject.sub(/(subversion="1.2") (version="1")/, '\2 \1')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal payload_array
    end

    it "must ignore name extensions of named associations" do
      alt_subject = subject.sub(/UniUid/, 'UniUidAssoc')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal payload_array
    end

    it "must leave whitespace in elements as is" do
      alt_subject = subject.sub(/<noSeq>1/, '<noSeq> 1')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).wont_equal payload_array
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal ["SerUid", "UniUid", "region", "LF", "txtName", "STRASBOURG APP", "codeType", "subversion", "1.2", "version", "1", "APP", "noSeq", " 1"]
    end

    it "must leave whitespace in attributes as is" do
      alt_subject = subject.sub(/subversion="1.2"/, 'subversion=" 1.2"')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).wont_equal payload_array
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal ["SerUid", "UniUid", "region", "LF", "txtName", "STRASBOURG APP", "codeType", "subversion", " 1.2", "version", "1", "APP", "noSeq", "1"]
    end

    it "must include empty elements" do
      alt_subject = subject.sub(/<noSeq>1</, '<noSeq><')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).wont_equal payload_array
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal ["SerUid", "UniUid", "region", "LF", "txtName", "STRASBOURG APP", "codeType", "subversion", "1.2", "version", "1", "APP", "noSeq", ""]
    end

    it "must include empty attributes" do
      alt_subject = subject.sub(/subversion="1.2"/, 'subversion=""')
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).wont_equal payload_array
      _(AIXM::PayloadHash.new(alt_subject).send(:payload_array)).must_equal ["SerUid", "UniUid", "region", "LF", "txtName", "STRASBOURG APP", "codeType", "subversion", "", "version", "1", "APP", "noSeq", "1"]
    end
  end

  describe :to_uuid do
    it "calculates correct UUIDv3 payload hash" do
      _(AIXM::PayloadHash.new(subject).to_uuid).must_equal payload_hash
    end
  end

  describe :uuid_for do
    subject do
      AIXM::PayloadHash.new('')
    end

    it "must digest single string" do
      _(subject.send(:uuid_for, %w(a))).must_equal "0cc175b9-c0f1-b6a8-31c3-99e269772661"
    end

    it "must digest double string" do
      _(subject.send(:uuid_for, %w(a b))).must_equal "d0726241-0206-76b1-4aa6-298ce6a18b21"
    end

    it "must digest integer" do
      _(subject.send(:uuid_for, [5])).must_equal "e4da3b7f-bbce-2345-d777-2b0674a318d5"
    end

    it "must digest nested array" do
      _(subject.send(:uuid_for, [1, [2, 3]])).must_equal "02b12e93-0c8b-cc7e-92e7-4ff5d96ce118"
    end

    it "must digest float" do
      _(subject.send(:uuid_for, [5.0])).must_equal "336669db-e720-233e-d557-7ddf81b653d3"
    end

    it "must digest boolean" do
      _(subject.send(:uuid_for, [true, false])).must_equal "215c2d45-b491-f5c8-15ac-e782ce450fdf"
    end

    it "must digest empty string" do
      _(subject.send(:uuid_for, ['', ''])).must_equal "b99834bc-19bb-ad24-580b-3adfa04fb947"
    end

    it "must digest nil identically to empty string" do
      _(subject.send(:uuid_for, [nil, nil])).must_equal subject.send(:uuid_for, ['', ''])
    end
  end
end

describe AIXM::PayloadHash::Mid do
  subject do
    <<~END
      <?xml version="1.0" encoding="utf-8"?>
      <OFMX-Snapshot>
        <Ser source="LF|AD|AD-2|2019-10-10|2047" active="true" type="essential">
          <SerUid>
            <UniUid region="LF">
              <txtName>STRASBOURG APP</txtName>
            </UniUid>
            <codeType subversion="1.2" version="1">APP</codeType>
            <noSeq>1</noSeq>
          </SerUid>
          <OrgUidAssoc mid="fd2b4e07-5a80-d3f6-63f2-660d07265922">
            <txtName></txtName>
          </OrgUidAssoc>
          <Stt priority="1">
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <Stt priority="2" authority="false">
            <codeWorkHr author="">HX</codeWorkHr>
          </Stt>
          <txtRmk> aka STRASBOURG approche</txtRmk>
        </Ser>
      </OFMX-Snapshot>
    END
  end

  describe :insert_mid do
    it "calculates and inserts OFMX-compliant mid attributes" do
      _(AIXM::PayloadHash::Mid.new(subject).insert_mid.to_xml).must_equal <<~END
        <?xml version="1.0" encoding="utf-8"?>
        <OFMX-Snapshot>
          <Ser source="LF|AD|AD-2|2019-10-10|2047" active="true" type="essential">
            <SerUid mid="6201128f-cdc1-59f4-1858-f30bdfc7f0d3">
              <UniUid region="LF" mid="1e86ce9b-04c3-a3fe-a0c2-9bd60895f62f">
                <txtName>STRASBOURG APP</txtName>
              </UniUid>
              <codeType subversion="1.2" version="1">APP</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <OrgUidAssoc mid="fd2b4e07-5a80-d3f6-63f2-660d07265922">
              <txtName/>
            </OrgUidAssoc>
            <Stt priority="1">
              <codeWorkHr>H24</codeWorkHr>
            </Stt>
            <Stt priority="2" authority="false">
              <codeWorkHr author="">HX</codeWorkHr>
            </Stt>
            <txtRmk> aka STRASBOURG approche</txtRmk>
          </Ser>
        </OFMX-Snapshot>
      END
    end
  end
end
