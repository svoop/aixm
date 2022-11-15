require_relative '../../../spec_helper'

describe AIXM::Feature::Generic do
  describe :fragment= do
    subject do
      AIXM::Factory.generic
    end

    it "accepts document fragment" do
      _(subject.tap { _1.fragment = Nokogiri::XML::DocumentFragment.parse('<foo/>') }.to_xml).must_equal <<~END
        <!-- Generic -->
        <foo/>
      END
    end

    it "accepts raw XML string" do
      _(subject.tap { _1.fragment = '<foo/>' }.to_xml).must_equal <<~END
        <!-- Generic -->
        <foo/>
      END
    end
  end

  describe :to_xml do
    it "builds correct AIXM from pretty XML" do
      _(AIXM::Factory.generic(pretty: true).to_xml).must_equal <<~END
        <!-- Generic -->
        <Org>
          <OrgUid>
            <txtName>EUROPE</txtName>
          </OrgUid>
          <codeType>GS</codeType>
        </Org>
      END
    end

    it "builds correct AIXM from pretty XML" do
      _(AIXM::Factory.generic(pretty: false).to_xml).must_equal <<~END
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
