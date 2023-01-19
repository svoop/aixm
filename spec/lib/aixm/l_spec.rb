require_relative '../../spec_helper'

describe AIXM::L do
  subject do
    AIXM::Factory.l
  end

  describe :initialize do
    it "initializes line without starting line point" do
      _(AIXM.l.line_points.count).must_equal 0
    end

    it "initializes line with starting line point" do
      _(AIXM.l(xy: AIXM::Factory.xy).line_points.count).must_equal 1
      _(AIXM.l(xy: AIXM::Factory.xy, z: AIXM::Factory.z).line_points.count).must_equal 1
    end
  end

  describe :add_line_point do
    it "fails on invalid arguments" do
      _{ subject.add_line_point(xy: 1) }.must_raise ArgumentError
      _{ subject.add_line_point(xy: 1, z: 2) }.must_raise ArgumentError
    end

    it "requires at least xy" do
      _{ subject.add_line_point }.must_raise ArgumentError
      _{ subject.add_line_point(z: 2) }.must_raise ArgumentError
    end

    it "returns self to allow chaining" do
      extended = subject.add_line_point(xy: AIXM::Factory.xy)
      _(extended).must_be_instance_of AIXM::L
      _(extended.line_points.count).must_equal 3
    end
  end

  describe :line? do
    it "returns false if not enough line points are defined" do
      _(AIXM.l).wont_be :line?
      _(AIXM.l(xy: AIXM::Factory.xy)).wont_be :line?
    end

    it "returns true if enough line points are defined" do
      _(subject).must_be :line?
    end
  end

  describe :line_points do
    it "returns line points as OpenStruct" do
      _(subject.line_points.first).must_be_instance_of OpenStruct
      _(subject.line_points.first.xy).must_be_instance_of AIXM::XY
      _(subject.line_points.first.z).must_be_instance_of AIXM::Z
    end
  end

  describe :== do
    it "recognizes line with identical line points as equal" do
      _(subject).must_equal subject.dup
    end

    it "recognizes line with different line points as not equal" do
      _(subject).wont_equal AIXM.l
    end
  end
end
