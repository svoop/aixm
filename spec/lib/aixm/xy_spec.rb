require_relative '../../spec_helper'

describe AIXM::XY do
  subject do
    AIXM::Factory.xy
  end

  describe :lat= do
    it "fails on invalid values" do
      _([91, "foobar"]).wont_be_written_to subject, :lat
    end

    it "parses valid DD values" do
      _(subject.tap { _1.lat = 11.2233 }.lat).must_equal 11.2233
    end

    it "parses valid DMS values"  do
      _(subject.tap { _1.lat = %q(11°22'33"N) }.lat).must_equal(11.37583333)
      _(subject.tap { _1.lat = %q(11°22'33"S) }.lat).must_equal(-11.37583333)
    end
  end

  describe :lat do
    context "north" do
      subject do
        AIXM.xy(lat: 1.1234, long: 0)
      end

      it "must format DD (default) correctly" do
        _(subject.lat).must_equal 1.1234
      end

      it "must format AIXM correctly" do
        _(subject.lat(:aixm)).must_equal %q(010724.24N)
      end

      it "must format OFM correctly" do
        _(subject.lat(:ofmx)).must_equal '01.12340000N'
      end
    end

    context "south" do
      subject do
        AIXM.xy(lat: -1.1234, long: 0)
      end

      it "must format DD (default) correctly" do
        _(subject.lat).must_equal(-1.1234)
      end

      it "must format AIXM correctly" do
        _(subject.lat(:aixm)).must_equal %q(010724.24S)
      end

      it "must format OFM correctly" do
        _(subject.lat(:ofmx)).must_equal '01.12340000S'
      end
    end
  end

  describe :long= do
    it "fails on invalid values" do
      _([181, "foobar"]).wont_be_written_to subject, :lat
    end

    it "parses valid DD values" do
      _(subject.tap { _1.long = 22.3344 }.long).must_equal 22.3344
    end

    it "parses valid DMS values"  do
      _(subject.tap { _1.long = %q(22°33'44"E) }.long).must_equal(22.56222222)
      _(subject.tap { _1.long = %q(22°33'44"W) }.long).must_equal(-22.56222222)
    end
  end

  describe :long do
    context "east" do
      subject do
        AIXM.xy(lat: 0, long: 1.1234)
      end

      it "must format DD (default) correctly" do
        _(subject.long).must_equal 1.1234
      end

      it "must format AIXM correctly" do
        _(subject.long(:aixm)).must_equal %q(0010724.24E)
      end

      it "must format OFM correctly" do
        _(subject.long(:ofmx)).must_equal '001.12340000E'
      end
    end

    context "west" do
      subject do
        AIXM.xy(lat: 0, long: -1.1234)
      end

      it "must format DD (default) correctly" do
        _(subject.long).must_equal(-1.1234)
      end

      it "must format AIXM correctly" do
        _(subject.long(:aixm)).must_equal %q(0010724.24W)
      end

      it "must format OFM correctly" do
        _(subject.long(:ofmx)).must_equal '001.12340000W'
      end
    end
  end

  describe :seconds? do
    it "must detect coordinates with zero DMS seconds" do
      _(AIXM.xy(lat: %q(44°33'00"N), long: %q(004°03'00"E))).wont_be :seconds?
      _(AIXM.xy(lat: %q(44°33'00.01"N), long: %q(004°03'00"E))).must_be :seconds?
      _(AIXM.xy(lat: %q(44°33'00"N), long: %q(004°03'00.01"E))).must_be :seconds?
      _(AIXM.xy(lat: %q(47°29'10"N), long: %q(000°33'15"W))).must_be :seconds?
      _(AIXM.xy(lat: %q(44°36'50"N), long: %q(004°23'50"E))).must_be :seconds?
      _(AIXM.xy(lat: %q(44°48'00"N), long: %q(000°34'27"W))).must_be :seconds?
    end
  end

  describe :to_point do
    subject do
      AIXM.xy(lat: %q(44°00'07.63"N), long: %q(004°45'07.81"E))
    end

    it "must return a point object with these coordinates" do
      _(subject.to_point.xy).must_equal AIXM.point(xy: subject).xy
    end
  end

  context "distances and bearings" do
    let :a do
      AIXM.xy(lat: %q(44°00'07.63"N), long: %q(004°45'07.81"E))
    end

    let :b do
      AIXM.xy(lat: %q(43°59'25.31"N), long: %q(004°45'23.24"E))
    end

    describe :distance do
      it "calculates the distance between two points correctly" do
        _(a.distance(b)).must_equal AIXM.d(1351, :m)
      end

      it "calculates the distance between the same point as zero" do
        _(a.distance(a)).must_equal AIXM.d(0, :m)
      end
    end

    describe :bearing do
      it "calculates the bearing to another point" do
        _(a.bearing(b).deg).must_be_close_to 165.3014
      end

      it "fails to calculate the bearing between two identical points" do
        _{ a.bearing(a) }.must_raise RuntimeError
      end
    end

    describe :add_distance do
      it "calculates the desination point" do
        dest = a.add_distance(AIXM.d(1351, :m), AIXM.a(165.3014))
        _(dest.lat).must_be_close_to(b.lat, 0.00001)     # approx 1m tolerance
        _(dest.long).must_be_close_to(b.long, 0.00001)   # approx 1m tolerance
      end
    end
  end

  describe :== do
    it "recognizes objects with identical latitude and longitude as equal" do
      a = AIXM.xy(lat: "112233N", long: "0223344E")
      b = AIXM.xy(lat: 11.37583333, long: 22.56222222)
      _(a).must_equal b
    end

    it "recognizes objects with different latitude or longitude as unequal" do
      a = AIXM.xy(lat: "112233.44N", long: "0223344.55E")
      b = AIXM.xy(lat: 11, long: 22)
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.xy(lat: "112233.44N", long: "0223344.55E")
      b = :oggy
      _(a).wont_equal b
    end
  end

  describe :hash do
    it "returns an integer" do
      _(subject.hash).must_be_instance_of Integer
    end

    it "allows for the use of instances as hash keys" do
      dupe = subject.dup
      _({ subject => true }[dupe]).must_equal true
    end
  end
end
