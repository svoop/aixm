require_relative '../../spec_helper'

using AIXM::Refinements

describe AIXM::Refinements do

  describe 'Array#to_digest' do
    it "must digest single string" do
      %w(a).to_digest.must_equal Digest::MD5.hexdigest('a')[0, 8]
    end

    it "must digest double string" do
      %w(a b).to_digest.must_equal Digest::MD5.hexdigest('a|b')[0, 8]
    end

    it "must digest integer" do
      [5].to_digest.must_equal Digest::MD5.hexdigest('5')[0, 8]
    end

    it "must digest float" do
      [5.0].to_digest.must_equal Digest::MD5.hexdigest('5.0')[0, 8]
    end

    it "must digest boolean" do
      [true, false].to_digest.must_equal Digest::MD5.hexdigest('true|false')[0, 8]
    end

    it "must digest nil" do
      [nil].to_digest.must_equal Digest::MD5.hexdigest('')[0, 8]
    end
  end

  describe 'String#indent' do
    it "must indent single line string" do
      'foobar'.indent(2).must_equal '  foobar'
    end

    it "must indent multi line string" do
      "foo\nbar".indent(2).must_equal "  foo\n  bar"
      "foo\nbar\n".indent(2).must_equal "  foo\n  bar\n"
    end
  end

end
