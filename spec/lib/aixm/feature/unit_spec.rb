require_relative '../../../spec_helper'

describe AIXM::Feature::Unit do
  subject do
    AIXM::Factory.unit
  end

  describe :organisation= do
    macro :organisation
  end

  describe :name= do
    it "fails on invalid values" do
      -> { subject.name = nil }.must_raise ArgumentError
    end

    it "upcases and transcodes valid values" do
      subject.tap { |s| s.name = 'Nîmes-Alès APP' }.name.must_equal 'NIMES-ALES APP'
    end
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
      -> { subject.type = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.type = :flight_information_centre }.type.must_equal :flight_information_centre
      subject.tap { |s| s.type = :MET }.type.must_equal :meteorological_office
    end
  end

  describe :class= do
    it "fails on invalid values" do
      -> { subject.class = :foobar }.must_raise ArgumentError
      -> { subject.class = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.class = :icao }.class.must_equal :icao
      subject.tap { |s| s.class = :OTHER }.class.must_equal :other
    end
  end

  describe :remarks= do
    macro :remarks
  end

  describe :to_xml do
    it "must build correct OFMX" do
      AIXM.ofmx!
      subject.to_xml.must_equal <<~END
        <Uni source="LF|GEN|0.0 FACTORY|0|0">
          <UniUid region="LF">
            <txtName>PUJAUT TWR</txtName>
          </UniUid>
          <OrgUid region="LF">
            <txtName>FRANCE</txtName>
          </OrgUid>
          <AhpUid region="LF">
            <codeId>LFNT</codeId>
          </AhpUid>
          <codeType>TWR</codeType>
          <codeClass>ICAO</codeClass>
          <txtRmk>A/A FR only</txtRmk>
        </Uni>
      END
    end
  end
end
