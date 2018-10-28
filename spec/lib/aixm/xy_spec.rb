require_relative '../../spec_helper'

describe AIXM::XY do
  subject do
    AIXM::Factory.xy
  end

  describe :lat= do
    it "fails on invalid values" do
      [91, "foobar"].wont_be_written_to subject, :lat
    end

    it "parses valid DD values" do
      subject.tap { |s| s.lat = 11.2233 }.lat.must_equal 11.2233
    end

    it "parses valid DMS values"  do
      subject.tap { |s| s.lat = %q(11°22'33"N) }.lat.must_equal(11.37583333)
      subject.tap { |s| s.lat = %q(11°22'33"S) }.lat.must_equal(-11.37583333)
    end
  end

  describe :lat do
    context "north" do
      subject do
        AIXM.xy(lat: 1.1234, long: 0)
      end

      it "must format DD (default) correctly" do
        subject.lat.must_equal 1.1234
      end

      it "must format AIXM correctly" do
        subject.lat(:aixm).must_equal %q(010724.24N)
      end

      it "must format OFM correctly" do
        subject.lat(:ofmx).must_equal '01.12340000N'
      end
    end

    context "south" do
      subject do
        AIXM.xy(lat: -1.1234, long: 0)
      end

      it "must format DD (default) correctly" do
        subject.lat.must_equal(-1.1234)
      end

      it "must format AIXM correctly" do
        subject.lat(:aixm).must_equal %q(010724.24S)
      end

      it "must format OFM correctly" do
        subject.lat(:ofmx).must_equal '01.12340000S'
      end
    end
  end

  describe :long= do
    it "fails on invalid values" do
      [181, "foobar"].wont_be_written_to subject, :lat
    end

    it "parses valid DD values" do
      subject.tap { |s| s.long = 22.3344 }.long.must_equal 22.3344
    end

    it "parses valid DMS values"  do
      subject.tap { |s| s.long = %q(22°33'44"E) }.long.must_equal(22.56222222)
      subject.tap { |s| s.long = %q(22°33'44"W) }.long.must_equal(-22.56222222)
    end
  end

  describe :long do
    context "east" do
      subject do
        AIXM.xy(lat: 0, long: 1.1234)
      end

      it "must format DD (default) correctly" do
        subject.long.must_equal 1.1234
      end

      it "must format AIXM correctly" do
        subject.long(:aixm).must_equal %q(0010724.24E)
      end

      it "must format OFM correctly" do
        subject.long(:ofmx).must_equal '001.12340000E'
      end
    end

    context "west" do
      subject do
        AIXM.xy(lat: 0, long: -1.1234)
      end

      it "must format DD (default) correctly" do
        subject.long.must_equal(-1.1234)
      end

      it "must format AIXM correctly" do
        subject.long(:aixm).must_equal %q(0010724.24W)
      end

      it "must format OFM correctly" do
        subject.long(:ofmx).must_equal '001.12340000W'
      end
    end
  end

  describe :== do
    it "recognizes objects with identical latitude and longitude as equal" do
      a = AIXM.xy(lat: "112233N", long: "0223344E")
      b = AIXM.xy(lat: 11.37583333, long: 22.56222222)
      a.must_equal b
    end

    it "recognizes objects with different latitude or longitude as unequal" do
      a = AIXM.xy(lat: "112233.44N", long: "0223344.55E")
      b = AIXM.xy(lat: 11, long: 22)
      a.wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.xy(lat: "112233.44N", long: "0223344.55E")
      b = :oggy
      a.wont_equal b
    end
  end

  describe :distance do
    subject do
      AIXM.xy(lat: %q(44°00'07.63"N), long: %q(004°45'07.81"E))
    end

    it "calculates the distance between the same point as zero" do
      subject.distance(subject).must_equal AIXM.d(0, :m)
    end

    it "calculates the distance between two points correctly" do
      other = AIXM.xy(lat: %q(43°59'25.31"N), long: %q(004°45'23.24"E))
      subject.distance(other).must_equal AIXM.d(1351, :m)
    end
  end
end
