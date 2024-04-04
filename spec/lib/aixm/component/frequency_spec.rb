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
      _(subject.reception_f).must_equal subject.transmission_f
    end
  end

  describe :transmission_f= do
    it "fails on invalid values" do
      _([nil, :foobar, 123, AIXM.f(100, :mhz)]).wont_be_written_to subject, :transmission_f
    end

    it "accepts valid values" do
      _([AIXM::Factory.f]).must_be_written_to subject, :transmission_f
    end

    it "assigns emergency type for emergency transmission frequencies" do
      subject.transmission_f = AIXM::EMERGENCY
      _(subject.type).must_equal :emergency
    end

    it "assigns emergency type for emergency reception frequencies" do
      subject.reception_f = AIXM::EMERGENCY
      _(subject.type).must_equal :emergency
    end
  end

  describe :callsigns= do
    it "fails on invalid values" do
      _([nil, :foobar, 123]).wont_be_written_to subject, :callsigns
    end

    it "downcases language codes" do
      _(subject.tap { _1.callsigns = { EN: "FOOBAR" } }.callsigns).must_equal(en: "FOOBAR")
    end

    it "upcases and transcodes callsigns" do
      _(subject.tap { _1.callsigns = { fr: "Nîmes-Alès" } }.callsigns).must_equal(fr: "NIMES-ALES")
    end
  end

  describe :reception_f= do
    it "fails on invalid values" do
      _([:foobar, 123, AIXM.f(100, :mhz)]).wont_be_written_to subject, :reception_f
    end

    it "accepts valid values" do
      _([nil, AIXM::Factory.f]).must_be_written_to subject, :reception_f
    end
  end

  describe :type= do
    it "fails on invalid values" do
      _{ subject.type = :foobar }.must_raise ArgumentError
    end

    it "accepts nil value" do
      _([nil]).must_be_written_to subject, :type
    end

    it "looks up valid values" do
      _(subject.tap { _1.type = :standard }.type).must_equal :standard
      _(subject.tap { _1.type = :ALT }.type).must_equal :alternative
    end
  end

  describe :timetable= do
    macro :timetable
  end

  describe :remarks= do
    macro :remarks
  end
end
