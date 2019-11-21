require_relative '../../../spec_helper'

describe AIXM::Feature::Organisation do
  subject do
    AIXM::Factory.organisation
  end

  describe :name= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :name
    end

    it "upcases and transcodes valid values" do
      _(subject.tap { |s| s.name = 'Nîmes-Alès' }.name).must_equal 'NIMES-ALES'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { |s| s.type = :state }.type).must_equal :state
      _(subject.tap { |s| s.type = :IO }.type).must_equal :international_organisation
    end
  end

  describe :id= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :id
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :id
    end

    it "upcases valid values" do
      _(subject.tap { |s| s.id = 'lf' }.id).must_equal 'LF'
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    macro :mid

    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- Organisation: FRANCE -->
        <Org source="LF|GEN|0.0 FACTORY|0|0">
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeId>LF</codeId>
          <codeType>S</codeType>
          <txtRmk>Oversea departments not included</txtRmk>
        </Org>
      END
    end

    it "builds correct minimal OFMX" do
      AIXM.ofmx!
      subject.id = subject.remarks = nil
      _(subject.to_xml).must_equal <<~END
        <!-- Organisation: FRANCE -->
        <Org source="LF|GEN|0.0 FACTORY|0|0">
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeType>S</codeType>
        </Org>
      END
    end

    it "builds OFMX with mid" do
      AIXM.ofmx!
      AIXM.config.mid = true
      AIXM.config.region = 'LF'
      _(subject.to_xml).must_match /<OrgUid mid="b5fef8e2-ea45-7326-6b2f-38cb45cd21a8">/
    end
  end
end
