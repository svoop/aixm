require_relative '../../spec_helper'

describe AIXM::Z do
  describe :initialize do
    it "must parse valid Q code" do
      subject = AIXM::Z.new(alt: 111, code: :QNH)
      subject.alt.must_equal 111
      subject.code.must_equal :QNH
    end

    it "won't parse invalid Q code" do
      -> { AIXM::Z.new(alt: 111, code: :FOO) }.must_raise ArgumentError
    end
  end

  describe :== do
    it "recognizes objects with identical altitude and Q code as equal" do
      a = AIXM::Z.new(alt: 111, code: :QNH)
      b = AIXM::Z.new(alt: 111, code: :QNH)
      a.must_equal b
    end

    it "recognizes objects with different altitude or Q code as unequal" do
      a = AIXM::Z.new(alt: 111, code: :QNH)
      b = AIXM::Z.new(alt: 222, code: :QNH)
      a.wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM::Z.new(alt: 111, code: :QNH)
      b = :oggy
      a.wont_equal b
    end
  end

  describe :ground? do
    it "must detect ground" do
      AIXM::Z.new(alt: 0, code: :QFE).must_be :ground?
      AIXM::Z.new(alt: 111, code: :QFE).wont_be :ground?
      AIXM::Z.new(alt: 0, code: :QNH).wont_be :ground?
    end
  end

  describe :base do
    it "must return correct base" do
      AIXM::Z.new(alt: 0, code: :QFE).base.must_equal :ASFC
      AIXM::Z.new(alt: 0, code: :QNH).base.must_equal :AMSL
      AIXM::Z.new(alt: 0, code: :QNE).base.must_equal :AMSL
    end
  end
end
