require_relative '../../spec_helper'

describe AIXM::Z do
  describe :initialize do
    it "must parse valid Q code" do
      subject = AIXM.z(111, 'QNH')
      subject.alt.must_equal 111
      subject.code.must_equal :QNH
    end

    it "won't parse invalid Q code" do
      -> { AIXM.z(111, :FOO) }.must_raise ArgumentError
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      AIXM.z(111, :QNH).to_digest.must_equal 850101360
    end
  end

  describe :== do
    it "recognizes objects with identical altitude and Q code as equal" do
      a = AIXM.z(111, :QNH)
      b = AIXM.z(111, :QNH)
      a.must_equal b
    end

    it "recognizes objects with different altitude or Q code as unequal" do
      a = AIXM.z(111, :QNH)
      b = AIXM.z(222, :QNH)
      a.wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.z(111, :QNH)
      b = :oggy
      a.wont_equal b
    end
  end

  describe :QFE? do
    it "recognizes same Q code" do
      AIXM.z(111, :QFE).must_be :QFE?
    end

    it "doesn't recognize different Q code" do
      AIXM.z(111, :QNH).wont_be :QFE?
    end
  end

  describe :ground? do
    it "must detect ground" do
      AIXM.z(0, :QFE).must_be :ground?
      AIXM.z(111, :QFE).wont_be :ground?
      AIXM.z(0, :QNH).wont_be :ground?
    end
  end

  describe :base do
    it "must return the correct base" do
      AIXM.z(0, :QFE).base.must_equal :ASFC
      AIXM.z(0, :QNH).base.must_equal :AMSL
      AIXM.z(0, :QNE).base.must_equal :AMSL
    end
  end

  describe :unit do
    it "must return the correct unit" do
      AIXM.z(0, :QFE).unit.must_equal :FT
      AIXM.z(0, :QNH).unit.must_equal :FT
      AIXM.z(0, :QNE).unit.must_equal :FL
    end
  end
end
