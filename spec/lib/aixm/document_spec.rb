require_relative '../../spec_helper'

describe AIXM::Document do
  describe :initialize do
    it "won't accept invalid arguments" do
      -> { AIXM.document(created_at: 0) }.must_raise ArgumentError
      -> { AIXM.document(created_at: 'foobar') }.must_raise ArgumentError
      -> { AIXM.document(effective_at: 0) }.must_raise ArgumentError
      -> { AIXM.document(effective_at: 'foobar') }.must_raise ArgumentError
    end

    it "must accept strings" do
      string = '2018-01-01 12:00:00 +0100'
      AIXM.document(created_at: string).created_at.must_equal Time.parse(string)
      AIXM.document(effective_at: string).effective_at.must_equal Time.parse(string)
    end

    it "must accept dates" do
      date = Date.parse('2018-01-01')
      AIXM.document(created_at: date).created_at.must_equal date.to_time
      AIXM.document(effective_at: date).effective_at.must_equal date.to_time
    end

    it "must accept times" do
      time = Time.parse('2018-01-01 12:00:00 +0100')
      AIXM.document(created_at: time).created_at.must_equal time
      AIXM.document(effective_at: time).effective_at.must_equal time
    end

    it "must accept nils" do
      AIXM.document(created_at: nil).created_at.must_be :nil?
      AIXM.document(effective_at: nil).effective_at.must_be :nil?
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

=begin
    it "must build correct AIXM" do
      subject.to_xml.must_equal <<~"END"
      END
    end
=end
  end

  context "OFMX" do
    subject do
      AIXM.ofmx!
      AIXM::Factory.document
    end

    it "won't have errors" do
      subject.errors.must_equal []
    end

=begin
    it "must build correct OFMX" do
      subject.to_xml.must_equal <<~"END"
      END
    end
=end
  end
end
