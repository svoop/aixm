require_relative '../../spec_helper'

describe AIXM::Mid do
  subject do
    Object.new.tap do |object|
      object.extend(AIXM::Mid)
      object.define_singleton_method(:to_uid) do
        "<XxxUid>\n</XxxUid>\n"
      end
    end
  end

  describe :insert_mid do

    it "sets the @mid instance variable with implicit fallback region XX" do
      AIXM.config.region = nil
      subject.send(:insert_mid, subject.to_uid)
      _(subject.mid).must_equal "fb72c7db-4108-e49d-c4ea-5f46a3e7c2f3"
    end

    it "sets the @mid instance variable with explicit fallback region XX" do
      AIXM.config.region = 'XX'
      subject.send(:insert_mid, subject.to_uid)
      _(subject.mid).must_equal "fb72c7db-4108-e49d-c4ea-5f46a3e7c2f3"
    end

    it "sets the @mid instance variable with explicit region" do
      AIXM.config.region = 'LF'
      subject.send(:insert_mid, subject.to_uid)
      _(subject.mid).must_equal "fb72c7db-4108-e49d-c4ea-5f46a3e7c2f3"
    end

    it "doesn't set the @mid instance variable when set_attribute is false" do
      subject.send(:insert_mid, subject.to_uid, set_attribute: false)
      _(subject.mid).must_be :nil?
    end

    it "inserts the mid attribute if OFMX and mid config set" do
      AIXM.ofmx!
      AIXM.config.mid = true
      AIXM.config.region = nil
      _(subject.send(:insert_mid, subject.to_uid)).must_equal <<~"END"
        <XxxUid mid="fb72c7db-4108-e49d-c4ea-5f46a3e7c2f3">
        </XxxUid>
      END
    end

    it "doesn't insert the mid attribute if OFMX is not set" do
      AIXM.aixm!
      AIXM.config.mid = true
      AIXM.config.region = nil
      _(subject.send(:insert_mid, subject.to_uid)).must_equal <<~"END"
        <XxxUid>
        </XxxUid>
      END
    end

    it "doesn't insert the mid attribute if mid config is not set" do
      AIXM.ofmx!
      AIXM.config.mid = false
      AIXM.config.region = nil
      _(subject.send(:insert_mid, subject.to_uid)).must_equal <<~"END"
        <XxxUid>
        </XxxUid>
      END
    end
  end
end
