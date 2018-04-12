require_relative '../../../spec_helper'

describe AIXM::Component::Frequency do
  subject do
    AIXM::Factory.frequency
  end

  describe :initialize do
    it "sets defaults" do
      subject = AIXM::Component::Frequency.new(
        transmission_f: AIXM.f(123.35, :mhz),
        callsigns: { en: "PUJAUT CONTROL", fr: "PUJAUT CONTROLE" }
      )
      subject.reception_f.must_equal subject.transmission_f
    end
  end

  describe :transmission_f= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :transmission_f
    end

    it "accepts valid values" do
      [AIXM::Factory.f].must_be_written_to subject, :transmission_f
    end
  end

  describe :callsigns= do
    it "fails on invalid values" do
      [nil, :foobar, 123].wont_be_written_to subject, :callsigns
    end

    it "downcases language codes" do
      subject.tap { |s| s.callsigns = { EN: "FOOBAR" } }.callsigns.must_equal(en: "FOOBAR")
    end

    it "upcases and transcodes callsigns" do
      subject.tap { |s| s.callsigns = { fr: "Nîmes-Alès" } }.callsigns.must_equal(fr: "NIMES-ALES")
    end
  end

  describe :reception_f= do
    it "fails on invalid values" do
      [:foobar, 123].wont_be_written_to subject, :reception_f
    end

    it "accepts valid values" do
      [nil, AIXM::Factory.f].must_be_written_to subject, :reception_f
    end
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
    end

    it "accepts nil value" do
      [nil].must_be_written_to subject, :type
    end

    it "looks up valid values" do
      subject.tap { |s| s.type = :standard }.type.must_equal :standard
      subject.tap { |s| s.type = :ALT }.type.must_equal :alternative
    end
  end

  describe :timetable= do
    macro :timetable
  end

  describe :remarks= do
    macro :remarks
  end

end
