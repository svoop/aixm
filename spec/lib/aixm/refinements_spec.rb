require_relative '../../spec_helper'

using AIXM::Refinements

describe AIXM::Refinements do

  context Array do
    describe :to_digest do
      it "must digest single string" do
        _(%w(a).to_digest).must_equal "1f40fc92"
      end

      it "must digest double string" do
        _(%w(a b).to_digest).must_equal "3c075e5f"
      end

      it "must digest integer" do
        _([5].to_digest).must_equal "06df0537"
      end

      it "must digest nested array" do
        _([1, [2, 3]].to_digest).must_equal "e9609e81"
      end

      it "must digest float" do
        _([5.0].to_digest).must_equal "78fc651d"
      end

      it "must digest boolean" do
        _([true, false].to_digest).must_equal "79bdc67a"
      end

      it "must digest nil" do
        _([nil].to_digest).must_equal "cf83e135"
      end
    end

    describe :find do
      subject do
        [AIXM::Factory.dme, AIXM::Factory.ndb, AIXM::Factory.vor]
      end

      it "finds elements by exact class" do
        _(subject.find(is_a: AIXM::Feature::NavigationalAid::DME).count).must_equal 1
      end

      it "finds elements by fuzzy class" do
        _(subject.find(kind_of: AIXM::Feature).count).must_equal 3
      end

      it "finds elements by attribute" do
        _(subject.find(id: 'MMM').count).must_equal 1
      end

      it "finds elements by class and attributes" do
        _(subject.find(is_a: AIXM::Feature::NavigationalAid::DME, id: 'MMM', name: 'DME NAVAID').count).must_equal 1
      end

      it "returns empty array if nothing is found" do
        _(subject.find(is_a: Array).count).must_equal 0
      end
    end

    describe :duplicates do
      it "returns an array containing the duplicates" do
        _(%w(a b c b d e d f b).duplicates).must_equal %w(b d)
      end

      it "returns an empty array if no duplicates are present" do
        _(%w(a b c d e f g h i).duplicates).must_equal []
      end
    end
  end

  context Float do
    describe :to_dms do
      it "must convert +1. DD to DMS" do
        _(1.37595556.to_dms).must_equal %q(001°22'33.44")
      end

      it "must convert -1. DD to DMS" do
        _(-1.37595556.to_dms).must_equal %q(-001°22'33.44")
      end

      it "must convert +2. DD to DMS" do
        _(11.37595556.to_dms).must_equal %q(011°22'33.44")
      end

      it "must convert -2. DD to DMS" do
        _(-11.37595556.to_dms).must_equal %q(-011°22'33.44")
      end

      it "must convert +3. DD to DMS" do
        _(111.37595556.to_dms).must_equal %q(111°22'33.44")
      end

      it "must convert -3. DD to DMS" do
        _(-111.37595556.to_dms).must_equal %q(-111°22'33.44")
      end

      it "must convert DD to DMS with degrees only" do
        _(11.0.to_dms).must_equal %q(011°00'00.00")
      end

      it "must convert DD to DMS with degrees and minutes only" do
        _(11.36666667.to_dms).must_equal %q(011°22'00.00")
      end

      it "must convert DD to DMS with tenth of seconds only" do
        _(1.37594444.to_dms).must_equal %q(001°22'33.40")
      end

      it "must convert DD to DMS with whole seconds only" do
        _(1.37583333.to_dms).must_equal %q(001°22'33.00")
      end

      it "must convert DD to two zero padded DMS" do
        _(1.37595556.to_dms(2)).must_equal %q(01°22'33.44")
      end

      it "must convert DD to no zero padded DMS" do
        _(1.37595556.to_dms(0)).must_equal %q(1°22'33.44")
      end
    end

    describe :to_rad do
      it "must convert correctly" do
        _(0.0.to_rad).must_equal 0
        _(180.0.to_rad).must_equal Math::PI
        _(-123.0.to_rad).must_equal(-2.1467549799530254)
      end
    end
  end

  context Hash do
    describe :lookup do
      subject do
        { one: 1, two: 2, three: 3, four: :three }
      end

      it "must return value for key if key is present" do
        _(subject.lookup(:one)).must_equal 1
      end

      it "must return value if key is not found but value is present" do
        _(subject.lookup(1)).must_equal 1
      end

      it "must return value for key if both key and value are present" do
        _(subject.lookup(:three)).must_equal 3
      end

      it "returns default if neither key nor value are present" do
        _(subject.lookup(:foo, :default)).must_equal :default
        _(subject.lookup(:foo, nil)).must_be_nil
      end

      it "fails if neither key, value nor default are present" do
        _{ subject.lookup(:foo) }.must_raise KeyError
      end
    end
  end

  context Object do
    describe :then_if do
      subject do
        "foobar"
      end

      it "must return self if the condition is false" do
        _(subject.then_if(false) { |s| s.gsub(/o/, 'i') }).must_equal subject
      end

      it "must return apply the block if the condition is true" do
        _(subject.then_if(true) { |s| s.gsub(/o/, 'i') }).must_equal 'fiibar'
      end
    end
  end

  context Regexp do
    describe :decapture do
      it "should replace capture groups with non-capture groups" do
        _(/(foo) baz (bar)/.decapture).must_equal /(?-mix:(?:foo) baz (?:bar))/
        _(/(foo) baz (bar)/i.decapture).must_equal /(?i-mx:(?:foo) baz (?:bar))/
      end

      it "should replace named capture groups with non-capture groups" do
        _(/(?<a>foo) baz (?<b>bar)/.decapture).must_equal /(?-mix:(?:foo) baz (?:bar))/
        _(/(?<a>foo) baz (?<b>bar)/i.decapture).must_equal /(?i-mx:(?:foo) baz (?:bar))/
      end

      it "should not replace special groups" do
        _(/(?:foo) (?<=baz) bar/.decapture).must_equal /(?-mix:(?:foo) (?<=baz) bar)/
      end

      it "should not replace literal round brackets" do
        _(/\(foo\)/.decapture).must_equal /(?-mix:\(foo\))/
      end

      it "should replace literal backslash followed by literal round brackets" do
        _(/\\(foo\\)/.decapture).must_equal /(?-mix:\\(?:foo\\))/
      end
    end
  end

  context String do
    describe :to_class do
      it "must resolve class name to class" do
        _("String".to_class).must_equal String
      end

      it "must resolve namespaced class name to class" do
        _("AIXM::Feature::Address".to_class).must_equal AIXM::Feature::Address
      end
    end

    describe :inflect do
      subject do
        "AIXM::Feature::NavigationalAid"
      end

      it "must apply no inflection" do
        _(subject.inflect).must_equal subject
      end

      it "must apply single inflection" do
        _(subject.inflect(:demodulize)).must_equal "NavigationalAid"
      end

      it "must apply multiple inflections" do
        _(subject.inflect(:demodulize, :tableize, :pluralize)).must_equal "navigational_aids"
      end
    end

    describe :indent do
      it "must indent single line string" do
        _('foobar'.indent(2)).must_equal '  foobar'
      end

      it "must indent multi line string" do
        _("foo\nbar".indent(2)).must_equal "  foo\n  bar"
        _("foo\nbar\n".indent(2)).must_equal "  foo\n  bar\n"
      end
    end

    context "hash function" do
      subject do
        <<~END
          <?xml version="1.0" encoding="utf-8"?>
          <OFMX-Snapshot>
            <Ser source="LF|AD|AD-2|2019-10-10|2047" type="essential" active="true">
              <SerUid>
                <UniUid region="LF">
                  <txtName>STRASBOURG APP</txtName>
                </UniUid>
                <codeType version="1" subversion="2">APP</codeType>
                <noSeq>1</noSeq>
              </SerUid>
              <Stt priority="1" mid="83126b8d-f9a0-bbc8-5248-17a10f68c2a4">
                <codeWorkHr>H24</codeWorkHr>
              </Stt>
              <Stt priority="2">
                <codeWorkHr>HX</codeWorkHr>
              </Stt>
              <txtRmk>aka STRASBOURG approche</txtRmk>
            </Ser>
          </OFMX-Snapshot>
        END
      end
    end

    describe :to_dd do
      it "must convert +6.2 DMS to DD" do
        _(%q(12°34'56.78"N).to_dd).must_equal 12.58243888888889
        _(%q(12°34'56.78").to_dd).must_equal 12.58243888888889
        _(%q(12°34'56.78'').to_dd).must_equal 12.58243888888889
        _(%q(12 34 56.78).to_dd).must_equal 12.58243888888889
        _(%q(123456.78N).to_dd).must_equal 12.58243888888889
      end

      it "must convert -6.2 DMS to DD" do
        _(%q(12°34'56.78"S).to_dd).must_equal(-12.58243888888889)
        _(%q(-12°34'56.78").to_dd).must_equal(-12.58243888888889)
        _(%q(-12 34 56.78).to_dd).must_equal(-12.58243888888889)
        _(%q(123456.78S).to_dd).must_equal(-12.58243888888889)
      end

      it "must convert +7.2 DMS to DD" do
        _(%q(111°22'33.44"N).to_dd).must_equal 111.37595555555555
        _(%q(111°22'33.44").to_dd).must_equal 111.37595555555555
        _(%q(111 22 33.44).to_dd).must_equal 111.37595555555555
        _(%q(1112233.44N).to_dd).must_equal 111.37595555555555
      end

      it "must convert -7.2 DMS to DD" do
        _(%q(111°22'33.44"S).to_dd).must_equal(-111.37595555555555)
        _(%q(-111°22'33.44").to_dd).must_equal(-111.37595555555555)
        _(%q(-111 22 33.44).to_dd).must_equal(-111.37595555555555)
        _(%q(1112233.44S).to_dd).must_equal(-111.37595555555555)
      end

      it "must convert +6.1 DMS to DD" do
        _(%q(12°34'56.7"N).to_dd).must_equal 12.582416666666667
        _(%q(12°34'56.7").to_dd).must_equal 12.582416666666667
        _(%q(12 34 56.7).to_dd).must_equal 12.582416666666667
        _(%q(123456.7N).to_dd).must_equal 12.582416666666667
      end

      it "must convert -6.1 DMS to DD" do
        _(%q(12°34'56.7"S).to_dd).must_equal(-12.582416666666667)
        _(%q(-12°34'56.7").to_dd).must_equal(-12.582416666666667)
        _(%q(-12 34 56.7).to_dd).must_equal(-12.582416666666667)
        _(%q(123456.7S).to_dd).must_equal(-12.582416666666667)
      end

      it "must convert +7.1 DMS to DD" do
        _(%q(111°22'33.4"N).to_dd).must_equal 111.37594444444444
        _(%q(111°22'33.4").to_dd).must_equal 111.37594444444444
        _(%q(111 22 33.4).to_dd).must_equal 111.37594444444444
        _(%q(1112233.4N).to_dd).must_equal 111.37594444444444
      end

      it "must convert -7.1 DMS to DD" do
        _(%q(111°22'33.4"S).to_dd).must_equal(-111.37594444444444)
        _(%q(-111°22'33.4").to_dd).must_equal(-111.37594444444444)
        _(%q(-111 22 33.4).to_dd).must_equal(-111.37594444444444)
        _(%q(1112233.4S).to_dd).must_equal(-111.37594444444444)
      end

      it "must convert +6.0 DMS to DD" do
        _(%q(12°34'56"N).to_dd).must_equal 12.582222222222223
        _(%q(12°34'56").to_dd).must_equal 12.582222222222223
        _(%q(12 34 56).to_dd).must_equal 12.582222222222223
        _(%q(123456N).to_dd).must_equal 12.582222222222223
      end

      it "must convert -6.0 DMS to DD" do
        _(%q(12°34'56"S).to_dd).must_equal(-12.582222222222223)
        _(%q(-12°34'56").to_dd).must_equal(-12.582222222222223)
        _(%q(-12 34 56).to_dd).must_equal(-12.582222222222223)
        _(%q(123456S).to_dd).must_equal(-12.582222222222223)
      end

      it "must convert +7.0 DMS to DD" do
        _(%q(111°22'33"N).to_dd).must_equal 111.37583333333333
        _(%q(111°22'33").to_dd).must_equal 111.37583333333333
        _(%q(111 22 33).to_dd).must_equal 111.37583333333333
        _(%q(1112233N).to_dd).must_equal 111.37583333333333
      end

      it "must convert -7.0 DMS to DD" do
        _(%q(111°22'33"S).to_dd).must_equal(-111.37583333333333)
        _(%q(-111°22'33").to_dd).must_equal(-111.37583333333333)
        _(%q(-111 22 33).to_dd).must_equal(-111.37583333333333)
        _(%q(1112233S).to_dd).must_equal(-111.37583333333333)
      end

      it "must convert all cardinal directions to DD" do
        _(%q(111°22'33.44"N).to_dd).must_equal 111.37595555555555
        _(%q(111°22'33.44"E).to_dd).must_equal 111.37595555555555
        _(%q(111°22'33.44"S).to_dd).must_equal -111.37595555555555
        _(%q(111°22'33.44"W).to_dd).must_equal -111.37595555555555
      end

      it "must ignore minor typos when converting to DD" do
        _(%q(111°22'33,44"N).to_dd).must_equal 111.37595555555555
        _(%q(111°22'33.44"n).to_dd).must_equal 111.37595555555555
        _(%q(111°22"33.44"N).to_dd).must_equal 111.37595555555555
        _(%q(111°22'33.44'N).to_dd).must_equal 111.37595555555555
        _(%q(111°22'33.44" N).to_dd).must_equal 111.37595555555555
        _(%q(111° 22' 33.44" N).to_dd).must_equal 111.37595555555555
        _(%q(-111°22'33.44"S).to_dd).must_equal 111.37595555555555
      end

      it "must do all possible roundtrip conversions" do
        if ENV['SPEC_SCOPE'] == 'all'
          2.times.with_index do |degrees|
            60.times.with_index do |minutes|
              60.times.with_index do |seconds|
                100.times.with_index do |fractions|
                  subject = %q(%03d°%02d'%02d.%02d") % [degrees, minutes, seconds, fractions]
                  _(subject.to_dd.to_dms).must_equal subject
                end
              end
            end
          end
        else
          skip
        end
      end
    end

    describe :to_time do
      it "must convert valid dates and times" do
        subject = '2018-01-01 17:17 +00:00'
        _(subject.to_time).must_equal Time.parse(subject)
      end

      it "fails on invalid dates and times" do
        subject = '2018-01-77 17:17 +00:00'
        _{ subject.to_time }.must_raise ArgumentError
      end
    end

    describe :uptrans do
      it "must transliterate invalid characters" do
        _('DÉJÀ SCHÖN'.uptrans).must_equal 'DEJA SCHOEN'
      end
    end
  end
end
