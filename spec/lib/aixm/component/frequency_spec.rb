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
      -> { subject.transmission_f = :foobar }.must_raise ArgumentError
      -> { subject.transmission_f = nil }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.transmission_f = AIXM::Factory.f }.transmission_f.must_equal AIXM::Factory.f
    end
  end

  describe :callsigns= do
    it "fails on invalid values" do
      -> { subject.callsigns = :foobar }.must_raise ArgumentError
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
      -> { subject.reception_f = :foobar }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.reception_f = AIXM::Factory.f }.reception_f.must_equal AIXM::Factory.f
      subject.tap { |s| s.reception_f = nil }.reception_f.must_be :nil?
    end
  end

  describe :type= do
    it "fails on invalid values" do
      -> { subject.type = :foobar }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.type = :standard }.type.must_equal :standard
      subject.tap { |s| s.type = :ALT }.type.must_equal :alternative
      subject.tap { |s| s.type = nil }.type.must_be :nil?
    end
  end

  describe :schedule= do
    macro :schedule
  end

  describe :remarks= do
    macro :remarks
  end

end
