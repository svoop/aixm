require_relative '../../../spec_helper'

describe AIXM::Feature::Organisation do
  subject do
    AIXM::Factory.organisation
  end

  describe :name= do
    it "fails on invalid values" do
      -> { subject.name = nil }.must_raise ArgumentError
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'Nîmes-Alès' }.name.must_equal 'NIMES-ALES'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.type = :state }.type.must_equal :state
      subject.tap { |s| s.type = :IO }.type.must_equal :international_organisation
    end
  end

  describe :id= do
    it "fails on invalid values" do
      -> { subject.id = :foobar }.must_raise ArgumentError
    end

    it "accepts nil values" do
      subject.tap { |s| s.id = nil }.id.must_be :nil?
    end

    it "upcases valid values" do
      subject.tap { |s| s.id = 'lf' }.id.must_equal 'LF'
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
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
  end
end
