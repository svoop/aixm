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
      _(subject.tap { _1.name = 'Nîmes-Alès' }.name).must_equal 'NIMES-ALES'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { _1.type = :state }.type).must_equal :state
      _(subject.tap { _1.type = :IO }.type).must_equal :international_organisation
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
      _(subject.tap { _1.id = 'lf' }.id).must_equal 'LF'
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "builds correct complete OFMX" do
      AIXM.ofmx!
      _(subject.to_xml).must_equal <<~END
        <!-- Organisation: FRANCE -->
        <Org source="LF|GEN|0.0 FACTORY|0|0">
          <OrgUid region="LF">
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
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeType>S</codeType>
        </Org>
      END
    end
  end
end
