require_relative '../../spec_helper'

describe AIXM::Document do
  subject do
    AIXM.document
  end

  describe :initialize do
    it "sets defaults" do
      subject.features.must_equal []
    end
  end

  describe :namespace= do
    it "fails on invalid values" do
      -> { subject.namespace = 'foobar' }.must_raise ArgumentError
    end

    it "sets random UUID for nil value" do
      subject.tap { |s| s.namespace = nil }.namespace.must_match AIXM::Document::NAMESPACE_PATTERN
    end

    it "accepts UUID value" do
      uuid = SecureRandom.uuid
      subject.tap { |s| s.namespace = uuid }.namespace.must_equal uuid
    end
  end

  describe :created_at= do
    it "fails on invalid values" do
      -> { subject.created_at = :foobar }.must_raise ArgumentError
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      subject.tap { |s| s.created_at = string }.created_at.must_equal Time.parse(string)
    end

    it "falls back to effective_at first" do
      subject.effective_at = Time.now
      subject.created_at = nil
      subject.created_at.must_equal subject.effective_at
    end

    it "falls back to now second" do
      subject.created_at = nil
      subject.created_at.must_be_close_to Time.now
    end
  end

  describe :effective_at= do
    it "fails on invalid values" do
      -> { subject.effective_at = :foobar }.must_raise ArgumentError
    end

    it "parses dates and times" do
      string = '2018-01-01 12:00:00 +0100'
      subject.tap { |s| s.effective_at = string }.effective_at.must_equal Time.parse(string)
    end

    it "falls back to created_at first" do
      subject.effective_at = Time.now
      subject.effective_at = nil
      subject.effective_at.must_equal subject.created_at
    end

    it "falls back to now second" do
      subject.effective_at = nil
      subject.effective_at.must_be_close_to Time.now
    end
  end

  context "AIXM" do
    subject do
      AIXM.aixm!
      AIXM::Factory.document
    end

    it "won't have errors" do
      subject.errors.must_equal []
    end

#   it "must build correct AIXM" do
#     subject.to_xml.must_equal <<~"END"
#     END
#   end
  end

  context "OFMX" do
    subject do
      AIXM.ofmx!
      AIXM::Factory.document
    end

    it "won't have errors" do
      subject.errors.must_equal []
    end

#   it "must build correct OFMX" do
#     subject.to_xml.must_equal <<~"END"
#     END
#   end
  end
end
