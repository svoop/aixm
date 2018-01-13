require_relative '../../spec_helper'

using AIXM::Refinements

describe AIXM::Refinements do

  describe 'Array#to_digest' do
    it "must digest single string" do
      %w(a).to_digest.must_equal Digest::MD5.hexdigest('a')[0, 8].upcase
    end

    it "must digest double string" do
      %w(a b).to_digest.must_equal Digest::MD5.hexdigest('a|b')[0, 8].upcase
    end

    it "must digest integer" do
      [5].to_digest.must_equal Digest::MD5.hexdigest('5')[0, 8].upcase
    end

    it "must digest float" do
      [5.0].to_digest.must_equal Digest::MD5.hexdigest('5.0')[0, 8].upcase
    end

    it "must digest boolean" do
      [true, false].to_digest.must_equal Digest::MD5.hexdigest('true|false')[0, 8].upcase
    end

    it "must digest nil" do
      [nil].to_digest.must_equal Digest::MD5.hexdigest('')[0, 8].upcase
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

  describe 'String#to_dd' do
    it "must convert +6.2 DMS to DD" do
      %q(12°34'56.78").to_dd.must_equal 12.58243889
      %q(12 34 56.78).to_dd.must_equal 12.58243889
      %q(123456.78).to_dd.must_equal 12.58243889
    end

    it "must convert -6.2 DMS to DD" do
      %q(-12°34'56.78").to_dd.must_equal(-12.58243889)
      %q(-12 34 56.78).to_dd.must_equal(-12.58243889)
      %q(-123456.78).to_dd.must_equal(-12.58243889)
    end

    it "must convert +7.2 DMS to DD" do
      %q(111°22'33.44").to_dd.must_equal 111.37595556
      %q(111 22 33.44).to_dd.must_equal 111.37595556
      %q(1112233.44).to_dd.must_equal 111.37595556
    end

    it "must convert -7.2 DMS to DD" do
      %q(-111°22'33.44").to_dd.must_equal(-111.37595556)
      %q(-111 22 33.44).to_dd.must_equal(-111.37595556)
      %q(-1112233.44).to_dd.must_equal(-111.37595556)
    end

    it "must convert +6.1 DMS to DD" do
      %q(12°34'56.7").to_dd.must_equal 12.58241667
      %q(12 34 56.7).to_dd.must_equal 12.58241667
      %q(123456.7).to_dd.must_equal 12.58241667
    end

    it "must convert -6.1 DMS to DD" do
      %q(-12°34'56.7").to_dd.must_equal(-12.58241667)
      %q(-12 34 56.7).to_dd.must_equal(-12.58241667)
      %q(-123456.7).to_dd.must_equal(-12.58241667)
    end

    it "must convert +7.1 DMS to DD" do
      %q(111°22'33.4").to_dd.must_equal 111.37594444
      %q(111 22 33.4).to_dd.must_equal 111.37594444
      %q(1112233.4).to_dd.must_equal 111.37594444
    end

    it "must convert +7.1 DMS to DD" do
      %q(-111°22'33.4").to_dd.must_equal(-111.37594444)
      %q(-111 22 33.4).to_dd.must_equal(-111.37594444)
      %q(-1112233.4).to_dd.must_equal(-111.37594444)
    end

    it "must convert +6.0 DMS to DD" do
      %q(12°34'56").to_dd.must_equal 12.58222222
      %q(12 34 56).to_dd.must_equal 12.58222222
      %q(123456).to_dd.must_equal 12.58222222
    end

    it "must convert -6.0 DMS to DD" do
      %q(-12°34'56").to_dd.must_equal(-12.58222222)
      %q(-12 34 56).to_dd.must_equal(-12.58222222)
      %q(-123456).to_dd.must_equal(-12.58222222)
    end

    it "must convert +7.0 DMS to DD" do
      %q(111°22'33").to_dd.must_equal 111.37583333
      %q(111 22 33).to_dd.must_equal 111.37583333
      %q(1112233).to_dd.must_equal 111.37583333
    end

    it "must convert +7.0 DMS to DD" do
      %q(-111°22'33").to_dd.must_equal(-111.37583333)
      %q(-111 22 33).to_dd.must_equal(-111.37583333)
      %q(-1112233).to_dd.must_equal(-111.37583333)
    end
  end

  describe 'Float#to_dms' do

    it "must convert +1. DD to DMS" do
      1.37595556.to_dms.must_equal %q(001°22'33.44")
    end

    it "must convert -1. DD to DMS" do
      -1.37595556.to_dms.must_equal %q(-001°22'33.44")
    end

    it "must convert +2. DD to DMS" do
      11.37595556.to_dms.must_equal %q(011°22'33.44")
    end

    it "must convert -2. DD to DMS" do
      -11.37595556.to_dms.must_equal %q(-011°22'33.44")
    end

    it "must convert +3. DD to DMS" do
      111.37595556.to_dms.must_equal %q(111°22'33.44")
    end

    it "must convert -3. DD to DMS" do
      -111.37595556.to_dms.must_equal %q(-111°22'33.44")
    end

    it "must convert DD to DMS with tenth of seconds only" do
      1.37594444.to_dms.must_equal %q(001°22'33.40")
    end

    it "must convert DD to DMS with whole seconds only" do
      1.37583333.to_dms.must_equal %q(001°22'33.00")
    end

    it "must convert DD to two zero padded DMS" do
      1.37595556.to_dms(2).must_equal %q(01°22'33.44")
    end

    it "must convert DD to no zero padded DMS" do
      1.37595556.to_dms(0).must_equal %q(1°22'33.44")
    end
  end
end
