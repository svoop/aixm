require_relative '../../spec_helper'

describe AIXM::Feature do
  subject do
    AIXM.config.region = 'ZZ'
    AIXM::Feature.send(:new)
  end

  describe :initialize do
    it "falls back to default region" do
      _(subject.region).must_equal 'ZZ'
    end
  end

  describe :comment do
    it "accepts any String value" do
      _(['foobar']).must_be_written_to subject, :comment
    end

    it "accepts any stringifyable value" do
      _(subject.tap { _1.comment = :foobar }.comment).must_equal 'foobar'
      _(subject.tap { _1.comment = 123 }.comment).must_equal '123'
    end

    it "is included as oneline XML comment" do
      subject = AIXM::Factory.organisation
      subject.comment = "Generic"
      _(subject.to_xml.gsub(/\s+$/, '')).must_equal <<~END.strip
        <!-- Organisation: FRANCE -->
        <Org>
          <!-- Generic -->
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeId>LF</codeId>
          <codeType>S</codeType>
          <txtRmk>Oversea departments not included</txtRmk>
        </Org>
      END
    end

    it "is included as multiline XML comment" do
      subject = AIXM::Factory.organisation
      subject.comment = "AIP Facsimile:\nRelevant de la Direction des Services de la navigation aérienne, le\nSERVICE DE L'INFORMATION AERONAUTIQUE est l'organisme central chargé\nde l'information aéronautique française."
      _(subject.to_xml.gsub(/\s+$/, '')).must_equal <<~END.strip
        <!-- Organisation: FRANCE -->
        <Org>
          <!--
            AIP Facsimile:
            Relevant de la Direction des Services de la navigation aérienne, le
            SERVICE DE L'INFORMATION AERONAUTIQUE est l'organisme central chargé
            de l'information aéronautique française.
          -->
          <OrgUid>
            <txtName>FRANCE</txtName>
          </OrgUid>
          <codeId>LF</codeId>
          <codeType>S</codeType>
          <txtRmk>Oversea departments not included</txtRmk>
        </Org>
      END
    end
  end

  describe :meta do
    it "accepts any value" do
      _([:foobar, 123, Object.new]).must_be_written_to subject, :meta
    end
  end

  describe :source= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :source
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :source
    end
  end

  describe :region= do
    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :region
    end

    it "fails on invalid values" do
      _([:foobar, 123, 'A', 'AAA']).wont_be_written_to subject, :region
    end

    it "upcases valid values" do
      _(subject.tap { _1.region = 'lf' }.region).must_equal 'LF'
    end
  end

  describe :== do
    it "recognizes features with identical UID as equal" do
      a = AIXM::Factory.organisation
      b = AIXM::Factory.organisation
      _(a).must_equal b
    end

    it "recognizes features with different UID as unequal" do
      a = AIXM::Factory.polygon_airspace
      b = AIXM::Factory.circle_airspace
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM::Factory.organisation
      b = :oggy
      _(a).wont_equal b
    end
  end

end
