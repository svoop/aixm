require_relative '../../spec_helper'

describe AIXM::XY do
  describe :initialize do
    it "must parse valid DD" do
      subject = AIXM::XY.new(lat: 11.2233, long: 22.3344)
      subject.lat.must_equal 11.2233
      subject.long.must_equal 22.3344
    end

    it "must parse valid DMS N/E"  do
      subject = AIXM::XY.new(lat: "11 22 33 N", long: "22 33 44 E")
      subject.lat.must_equal 11.37583333
      subject.long.must_equal 22.56222222
    end

    it "must parse valid DMS S/W"  do
      subject = AIXM::XY.new(lat: "11 22 33 S", long: "22 33 44 W")
      subject.lat.must_equal(-11.37583333)
      subject.long.must_equal(-22.56222222)
    end

    it "must parse valid DMS with symbols"  do
      subject = AIXM::XY.new(lat: %q(11°22'33"N), long: %q(22°33'44"E))
      subject.lat.must_equal 11.37583333
      subject.long.must_equal 22.56222222
    end

    it "must parse valid DMS with fractions"  do
      subject = AIXM::XY.new(lat: "11 22 33.44 N", long: "22 33 44.55 E")
      subject.lat.must_equal 11.37595556
      subject.long.must_equal 22.562375
    end

    it "must not parse invalid latitude" do
      -> { AIXM::XY.new(lat: 91, long: 22.3344) }.must_raise ArgumentError
    end

    it "must not parse invalid longitude" do
      -> { AIXM::XY.new(lat: 11.2233, long: 181) }.must_raise ArgumentError
    end

    it "must not parse invalid DMS" do
      -> { AIXM::XY.new(lat: "foo", long: "bar") }.must_raise ArgumentError
    end
  end

  describe :lat do
    it "must format north latitude correctly" do
      subject = AIXM::XY.new(lat: 12.1234, long: 0)
      subject.lat.must_equal 12.1234
      subject.lat(:AIXM).must_equal '12.12340000N'
    end

    it "must format south latitude correctly" do
      subject = AIXM::XY.new(lat: -12.1234, long: 0)
      subject.lat.must_equal -12.1234
      subject.lat(:AIXM).must_equal '12.12340000S'
    end
  end

  describe :long do
    it "must format east longitude correctly" do
      subject = AIXM::XY.new(lat: 0, long: 23.123456789)
      subject.long.must_equal 23.12345679
      subject.long(:AIXM).must_equal '23.12345679E'
    end

    it "must format west longitude correctly" do
      subject = AIXM::XY.new(lat: 0, long: -23.123456789)
      subject.long.must_equal -23.12345679
      subject.long(:AIXM).must_equal '23.12345679W'
    end
  end

  describe :== do
    it "recognizes objects with identical latitude and longitude as equal" do
      a = AIXM::XY.new(lat: "11 22 33 N", long: "22 33 44 E")
      b = AIXM::XY.new(lat: 11.37583333, long: 22.56222222)
      a.must_equal b
    end

    it "recognizes objects with different latitude or longitude as unequal" do
      a = AIXM::XY.new(lat: "11 22 33.44 N", long: "22 33 44.55 E")
      b = AIXM::XY.new(lat: 11, long: 22)
      a.wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM::XY.new(lat: "11 22 33.44 N", long: "22 33 44.55 E")
      b = :oggy
      a.wont_equal b
    end
  end

end
