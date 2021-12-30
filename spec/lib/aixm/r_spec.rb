require_relative '../../spec_helper'

describe AIXM::R do
  subject do
    AIXM::Factory.r
  end

  describe :initialize do
    it "accepts one dimension" do
      _(AIXM.r(AIXM.d(1, :m)).to_s).must_equal '1.0 m x 1.0 m'
    end

    it "accepts two dimensions" do
      _(AIXM.r(AIXM.d(1, :m), AIXM.d(2, :m)).to_s).must_equal '2.0 m x 1.0 m'
    end
  end

  describe :length= do
    it "fails on invalid values" do
      _([:foobar, -1, 8, nil]).wont_be_written_to subject, :length
    end

    it "orders length and width" do
      subject.length = AIXM.d(1, :m)
      _(subject.length).must_equal AIXM.d(20, :m)
      _(subject.width).must_equal AIXM.d(1, :m)
    end
  end

  describe :width= do
    it "fails on invalid values" do
      _([:foobar, -1, 8, nil]).wont_be_written_to subject, :width
    end

    it "orders length and width" do
      subject.width = AIXM.d(100, :m)
      _(subject.length).must_equal AIXM.d(100, :m)
      _(subject.width).must_equal AIXM.d(25, :m)
    end
  end

  describe :surface do
    it "calculates the surface in square meters" do
      _(subject.surface).must_equal 500
    end
  end

  describe :== do
    it "recognizes objects with identical dimensions as equal" do
      a = AIXM.r(AIXM.d(1000, :m))
      b = AIXM.r(AIXM.d(1, :km))
      _(a).must_equal b
    end

    it "recognizes objects with different dimensions as unequal" do
      a = AIXM.r(AIXM.d(1, :m))
      b = AIXM.r(AIXM.d(2, :m))
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.r(AIXM.d(1, :m))
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
