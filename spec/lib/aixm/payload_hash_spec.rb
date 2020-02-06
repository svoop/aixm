require_relative '../../spec_helper'


describe AIXM::PayloadHash do
  subject do
    <<~END
      <SerUid>
        <UniUid region="LF">
          <txtName>STRASBOURG APP</txtName>
        </UniUid>
        <codeType version="1" subversion="2">APP</codeType>
        <noSeq>1</noSeq>
      </SerUid>
    END
  end

  let(:payload_hash) { "e24bf066-7ccf-28ab-971b-9c001f1ceff2" }

  describe :initialize do
    it "accepts and converts XML strings" do
      _(AIXM::PayloadHash.new(subject).fragment).must_be_instance_of Nokogiri::XML::DocumentFragment
    end

    it "accepts and clones XML fragment" do
      fragment = Nokogiri::XML.fragment(subject)
      hasher = AIXM::PayloadHash.new(fragment)
      _(hasher.fragment).must_be_instance_of Nokogiri::XML::DocumentFragment
      _(hasher.fragment).wont_equal fragment
    end
  end

  describe :payload_array do
    it "builds array of payload attributes and elements" do
      _(AIXM::PayloadHash.new(subject).send(:payload_array)).must_equal ["SerUid", "UniUid", "region", "LF", "txtName", "STRASBOURG APP", "codeType", "subversion", "2", "version", "1", "APP", "noSeq", "1"]
    end
  end

  describe :to_uuid do
    it "calculates the correct UUIDv3 payload hash" do
      _(AIXM::PayloadHash.new(subject).to_uuid).must_equal payload_hash
    end

    it "must ignore name extensions of named associations" do
      named_subject = subject.gsub(/<(.?)SerUid/, '<\1SerUidWithName')
      _(AIXM::PayloadHash.new(named_subject).to_uuid).must_equal payload_hash
    end

    it "must ignore mid attributes" do
      subject_with_mid = subject.sub(/(active="true")/, 'mid="123" \1')
      _(AIXM::PayloadHash.new(subject_with_mid).to_uuid).must_equal payload_hash
    end

    it "must ignore source attributes" do
      subject_with_source = subject.sub(/(active="true")/, 'source="123" \1')
      _(AIXM::PayloadHash.new(subject_with_source).to_uuid).must_equal payload_hash
    end

    it "must order the element arguments alphabetically" do
      subject_with_swap = subject.sub(/(active="true") (type="essential")/, '\2 \1')
      _(AIXM::PayloadHash.new(subject_with_swap).to_uuid).must_equal payload_hash
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

    it "must digest nil" do
      _(subject.send(:uuid_for, [nil])).must_equal "d41d8cd9-8f00-b204-e980-0998ecf8427e"
    end
  end
end


describe AIXM::PayloadHash::Mid do
  subject do
    <<~END
      <?xml version="1.0" encoding="utf-8"?>
      <OFMX-Snapshot>
        <Ser source="LF|AD|AD-2|2019-10-10|2047" type="essential" active="true">
          <SerUid>
            <UniUid region="LF">
              <txtName>STRASBOURG APP</txtName>
            </UniUid>
            <codeType version="1" subversion="2">APP</codeType>
            <noSeq>1</noSeq>
          </SerUid>
          <Stt priority="1" mid="83126b8d-f9a0-bbc8-5248-17a10f68c2a4">
            <codeWorkHr>H24</codeWorkHr>
          </Stt>
          <Stt priority="2">
            <codeWorkHr>HX</codeWorkHr>
          </Stt>
          <txtRmk>aka STRASBOURG approche</txtRmk>
        </Ser>
      </OFMX-Snapshot>
    END
  end

  describe :insert_mid do
    it "calculates and inserts OFMX-compliant mid attributes" do
      _(AIXM::PayloadHash::Mid.new(subject).insert_mid.to_xml).must_equal <<~END
        <?xml version="1.0" encoding="utf-8"?>
        <OFMX-Snapshot>
          <Ser source="LF|AD|AD-2|2019-10-10|2047" type="essential" active="true">
            <SerUid mid="e24bf066-7ccf-28ab-971b-9c001f1ceff2">
              <UniUid region="LF" mid="1e86ce9b-04c3-a3fe-a0c2-9bd60895f62f">
                <txtName>STRASBOURG APP</txtName>
              </UniUid>
              <codeType version="1" subversion="2">APP</codeType>
              <noSeq>1</noSeq>
            </SerUid>
            <Stt priority="1" mid="83126b8d-f9a0-bbc8-5248-17a10f68c2a4">
              <codeWorkHr>H24</codeWorkHr>
            </Stt>
            <Stt priority="2">
              <codeWorkHr>HX</codeWorkHr>
            </Stt>
            <txtRmk>aka STRASBOURG approche</txtRmk>
          </Ser>
        </OFMX-Snapshot>
      END
    end
  end
end
