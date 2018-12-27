require_relative '../../spec_helper'

using AIXM::Refinements

describe AIXM::Refinements do

  context Array do
    describe :to_digest do
      it "must digest single string" do
        %w(a).to_digest.must_equal "1f40fc92"
      end

      it "must digest double string" do
        %w(a b).to_digest.must_equal "3c075e5f"
      end

      it "must digest integer" do
        [5].to_digest.must_equal "06df0537"
      end

      it "must digest nested array" do
        [1, [2, 3]].to_digest.must_equal "e9609e81"
      end

      it "must digest float" do
        [5.0].to_digest.must_equal "78fc651d"
      end

      it "must digest boolean" do
        [true, false].to_digest.must_equal "79bdc67a"
      end

      it "must digest nil" do
        [nil].to_digest.must_equal "cf83e135"
      end
    end

    describe :to_uuid do
      it "must digest single string" do
        %w(a).to_uuid.must_equal "0cc175b9-c0f1-b6a8-31c3-99e269772661"
      end

      it "must digest double string" do
        %w(a b).to_uuid.must_equal "d0726241-0206-76b1-4aa6-298ce6a18b21"
      end

      it "must digest integer" do
        [5].to_uuid.must_equal "e4da3b7f-bbce-2345-d777-2b0674a318d5"
      end

      it "must digest nested array" do
        [1, [2, 3]].to_uuid.must_equal "02b12e93-0c8b-cc7e-92e7-4ff5d96ce118"
      end

      it "must digest float" do
        [5.0].to_uuid.must_equal "336669db-e720-233e-d557-7ddf81b653d3"
      end

      it "must digest boolean" do
        [true, false].to_uuid.must_equal "215c2d45-b491-f5c8-15ac-e782ce450fdf"
      end

      it "must digest nil" do
        [nil].to_uuid.must_equal "d41d8cd9-8f00-b204-e980-0998ecf8427e"
      end
    end
  end

  context Float do
    describe :to_dms do
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

      it "must convert DD to DMS with degrees only" do
        11.0.to_dms.must_equal %q(011°00'00.00")
      end

      it "must convert DD to DMS with degrees and minutes only" do
        11.36666667.to_dms.must_equal %q(011°22'00.00")
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

    describe :to_rad do
      it "must convert correctly" do
        0.0.to_rad.must_equal 0
        180.0.to_rad.must_equal Math::PI
        -123.0.to_rad.must_equal(-2.1467549799530254)
      end
    end
  end

  context Hash do
    describe :lookup do
      subject do
        { one: 1, two: 2, three: 3, four: :three }
      end

      it "must return value for key if key is present" do
        subject.lookup(:one).must_equal 1
      end

      it "must return value if key is not found but value is present" do
        subject.lookup(1).must_equal 1
      end

      it "must return value for key if both key and value are present" do
        subject.lookup(:three).must_equal 3
      end

      it "returns default if neither key nor value are present" do
        subject.lookup(:foo, :default).must_equal :default
        subject.lookup(:foo, nil).must_be_nil
      end

      it "fails if neither key, value nor default are present" do
        -> { subject.lookup(:foo) }.must_raise KeyError
      end
    end
  end

  context Regexp do
    describe :decapture do
      it "should replace capture groups with non-capture groups" do
        /(foo) baz (bar)/.decapture.must_equal /(?-mix:(?:foo) baz (?:bar))/
        /(foo) baz (bar)/i.decapture.must_equal /(?i-mx:(?:foo) baz (?:bar))/
      end

      it "should replace named capture groups with non-capture groups" do
        /(?<a>foo) baz (?<b>bar)/.decapture.must_equal /(?-mix:(?:foo) baz (?:bar))/
        /(?<a>foo) baz (?<b>bar)/i.decapture.must_equal /(?i-mx:(?:foo) baz (?:bar))/
      end

      it "should not replace special groups" do
        /(?:foo) (?<=baz) bar/.decapture.must_equal /(?-mix:(?:foo) (?<=baz) bar)/
      end

      it "should not replace literal round brackets" do
        /\(foo\)/.decapture.must_equal /(?-mix:\(foo\))/
      end

      it "should replace literal backslash followed by literal round brackets" do
        /\\(foo\\)/.decapture.must_equal /(?-mix:\\(?:foo\\))/
      end
    end
  end

  context String do
    describe :indent do
      it "must indent single line string" do
        'foobar'.indent(2).must_equal '  foobar'
      end

      it "must indent multi line string" do
        "foo\nbar".indent(2).must_equal "  foo\n  bar"
        "foo\nbar\n".indent(2).must_equal "  foo\n  bar\n"
      end
    end

    describe :payload_hash do
      subject do
        <<~END
          <?xml version="1.0" encoding="utf-8"?>
          <OFMX-Snapshot region="LF">
            <Ser type="essential" active="true">
              <SerUid>
                <UniUid>
                  <txtName>STRASBOURG APP</txtName>
                </UniUid>
                <codeType version="1" subversion="2">APP</codeType>
                <noSeq>1</noSeq>
              </SerUid>
              <Stt priority="1">
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

      it "must calculate the hash" do
        subject.payload_hash(region: 'LF', element: 'Ser').must_equal "269b1f18-cabe-3c9e-1d71-48a7414a4cb9"
      end
    end

    describe :to_dd do
      it "must convert +6.2 DMS to DD" do
        %q(12°34'56.78"N).to_dd.must_equal 12.58243888888889
        %q(12°34'56.78").to_dd.must_equal 12.58243888888889
        %q(12°34'56.78'').to_dd.must_equal 12.58243888888889
        %q(12 34 56.78).to_dd.must_equal 12.58243888888889
        %q(123456.78N).to_dd.must_equal 12.58243888888889
      end

      it "must convert -6.2 DMS to DD" do
        %q(12°34'56.78"S).to_dd.must_equal(-12.58243888888889)
        %q(-12°34'56.78").to_dd.must_equal(-12.58243888888889)
        %q(-12 34 56.78).to_dd.must_equal(-12.58243888888889)
        %q(123456.78S).to_dd.must_equal(-12.58243888888889)
      end

      it "must convert +7.2 DMS to DD" do
        %q(111°22'33.44"N).to_dd.must_equal 111.37595555555555
        %q(111°22'33.44").to_dd.must_equal 111.37595555555555
        %q(111 22 33.44).to_dd.must_equal 111.37595555555555
        %q(1112233.44N).to_dd.must_equal 111.37595555555555
      end

      it "must convert -7.2 DMS to DD" do
        %q(111°22'33.44"S).to_dd.must_equal(-111.37595555555555)
        %q(-111°22'33.44").to_dd.must_equal(-111.37595555555555)
        %q(-111 22 33.44).to_dd.must_equal(-111.37595555555555)
        %q(1112233.44S).to_dd.must_equal(-111.37595555555555)
      end

      it "must convert +6.1 DMS to DD" do
        %q(12°34'56.7"N).to_dd.must_equal 12.582416666666667
        %q(12°34'56.7").to_dd.must_equal 12.582416666666667
        %q(12 34 56.7).to_dd.must_equal 12.582416666666667
        %q(123456.7N).to_dd.must_equal 12.582416666666667
      end

      it "must convert -6.1 DMS to DD" do
        %q(12°34'56.7"S).to_dd.must_equal(-12.582416666666667)
        %q(-12°34'56.7").to_dd.must_equal(-12.582416666666667)
        %q(-12 34 56.7).to_dd.must_equal(-12.582416666666667)
        %q(123456.7S).to_dd.must_equal(-12.582416666666667)
      end

      it "must convert +7.1 DMS to DD" do
        %q(111°22'33.4"N).to_dd.must_equal 111.37594444444444
        %q(111°22'33.4").to_dd.must_equal 111.37594444444444
        %q(111 22 33.4).to_dd.must_equal 111.37594444444444
        %q(1112233.4N).to_dd.must_equal 111.37594444444444
      end

      it "must convert -7.1 DMS to DD" do
        %q(111°22'33.4"S).to_dd.must_equal(-111.37594444444444)
        %q(-111°22'33.4").to_dd.must_equal(-111.37594444444444)
        %q(-111 22 33.4).to_dd.must_equal(-111.37594444444444)
        %q(1112233.4S).to_dd.must_equal(-111.37594444444444)
      end

      it "must convert +6.0 DMS to DD" do
        %q(12°34'56"N).to_dd.must_equal 12.582222222222223
        %q(12°34'56").to_dd.must_equal 12.582222222222223
        %q(12 34 56).to_dd.must_equal 12.582222222222223
        %q(123456N).to_dd.must_equal 12.582222222222223
      end

      it "must convert -6.0 DMS to DD" do
        %q(12°34'56"S).to_dd.must_equal(-12.582222222222223)
        %q(-12°34'56").to_dd.must_equal(-12.582222222222223)
        %q(-12 34 56).to_dd.must_equal(-12.582222222222223)
        %q(123456S).to_dd.must_equal(-12.582222222222223)
      end

      it "must convert +7.0 DMS to DD" do
        %q(111°22'33"N).to_dd.must_equal 111.37583333333333
        %q(111°22'33").to_dd.must_equal 111.37583333333333
        %q(111 22 33).to_dd.must_equal 111.37583333333333
        %q(1112233N).to_dd.must_equal 111.37583333333333
      end

      it "must convert -7.0 DMS to DD" do
        %q(111°22'33"S).to_dd.must_equal(-111.37583333333333)
        %q(-111°22'33").to_dd.must_equal(-111.37583333333333)
        %q(-111 22 33).to_dd.must_equal(-111.37583333333333)
        %q(1112233S).to_dd.must_equal(-111.37583333333333)
      end

      it "must convert all cardinal directions to DD" do
        %q(111°22'33.44"N).to_dd.must_equal 111.37595555555555
        %q(111°22'33.44"E).to_dd.must_equal 111.37595555555555
        %q(111°22'33.44"S).to_dd.must_equal -111.37595555555555
        %q(111°22'33.44"W).to_dd.must_equal -111.37595555555555
      end

      it "must ignore minor typos when converting to DD" do
        %q(111°22'33,44"N).to_dd.must_equal 111.37595555555555
        %q(111°22'33.44"n).to_dd.must_equal 111.37595555555555
        %q(111°22"33.44"N).to_dd.must_equal 111.37595555555555
        %q(111°22'33.44'N).to_dd.must_equal 111.37595555555555
        %q(111°22'33.44" N).to_dd.must_equal 111.37595555555555
        %q(111° 22' 33.44" N).to_dd.must_equal 111.37595555555555
        %q(-111°22'33.44"S).to_dd.must_equal 111.37595555555555
      end

      it "must do all possible roundtrip conversions" do
        if ENV['SPEC_SCOPE'] == 'all'
          2.times.with_index do |degrees|
            60.times.with_index do |minutes|
              60.times.with_index do |seconds|
                100.times.with_index do |fractions|
                  subject = %q(%03d°%02d'%02d.%02d") % [degrees, minutes, seconds, fractions]
                  subject.to_dd.to_dms.must_equal subject
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
        subject.to_time.must_equal Time.parse(subject)
      end

      it "fails on invalid dates and times" do
        subject = '2018-01-77 17:17 +00:00'
        -> { subject.to_time }.must_raise ArgumentError
      end
    end

    describe :uptrans do
      it "must transliterate invalid characters" do
        'DÉJÀ SCHÖN'.uptrans.must_equal 'DEJA SCHOEN'
      end
    end
  end
end
