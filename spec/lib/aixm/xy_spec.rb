require_relative '../../spec_helper'

describe AIXM::XY do
  describe :initialize do
    it "must parse valid DD" do
      subject = AIXM.xy(lat: 11.2233, long: 22.3344)
      subject.lat.must_equal 11.2233
      subject.long.must_equal 22.3344
    end

    it "must parse valid DMS N/E"  do
      subject = AIXM.xy(lat: %q(11°22'33"N), long: %q(22°33'44"E))
      subject.lat.must_equal 11.37583333
      subject.long.must_equal 22.56222222
    end

    it "must parse valid DMS S/W"  do
      subject = AIXM.xy(lat: %q(11°22'33"S), long: %q(22°33'44"W))
      subject.lat.must_equal(-11.37583333)
      subject.long.must_equal(-22.56222222)
    end

    it "won't parse invalid latitude" do
      -> { AIXM.xy(lat: 91, long: 22.3344) }.must_raise ArgumentError
    end

    it "won't parse invalid longitude" do
      -> { AIXM.xy(lat: 11.2233, long: 181) }.must_raise ArgumentError
    end

    it "won't parse invalid DMS" do
      -> { AIXM.xy(lat: "foo", long: "bar") }.must_raise ArgumentError
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
        subject.lat(:ofmx).must_equal '1.12340000N'
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
        subject.lat(:ofmx).must_equal '1.12340000S'
      end
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
        subject.long(:ofmx).must_equal '1.12340000E'
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
        subject.long(:ofmx).must_equal '1.12340000W'
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
      subject.distance(subject).must_equal 0
    end

    it "calculates the distance between two points correctly in meters" do
      other = AIXM.xy(lat: %q(43°59'25.31"N), long: %q(004°45'23.24"E))
      subject.distance(other).must_equal 1351
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      AIXM::Factory.xy.to_digest.must_equal 783044788
    end
  end
end
