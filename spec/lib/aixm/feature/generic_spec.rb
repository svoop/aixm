require_relative '../../../spec_helper'

describe AIXM::Feature::Generic do
  subject do
    AIXM::Factory.generic
  end

  describe :xml= do
    it "accepts any values" do
      _(subject.tap { _1.xml = '<foo/>' }.to_xml).must_equal <<~END
        <!-- Generic -->
        <foo/>
      END
    end
  end

  describe :to_xml do
    it "builds correct AIXM" do
      _(subject.to_xml).must_equal <<~END
        <!-- Generic -->
        <Org>
          <OrgUid>
            <txtName>EUROPE</txtName>
          </OrgUid>
          <codeType>GS</codeType>
        </Org>
      END
    end
  end
end
