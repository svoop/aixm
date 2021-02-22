require_relative '../../spec_helper'

describe AIXM::F do
  subject do
    AIXM::Factory.f
  end

  describe :freq= do
    it "fails on invalid values" do
      _([:foobar]).wont_be_written_to subject, :freq
    end

    it "converts Numeric to Float" do
      _(subject.tap { _1.freq = 5 }.freq).must_equal 5.0
    end
  end

  describe :unit= do
    it "fails on invalid values" do
      _([:foobar, 123]).wont_be_written_to subject, :unit
    end

    it "symbolizes and downcases values" do
      _(subject.tap { _1.unit = "MHz" }.unit).must_equal :mhz
    end
  end

  describe :between? do
    subject do
      AIXM.f(100, :mhz)
    end

    it "detect frequencies within a frequency band" do
      _(subject.between?(90, 110, :mhz)).must_equal true
      _(subject.between?(90, 100, :mhz)).must_equal true
      _(subject.between?(100.0, 100.1, :mhz)).must_equal true
    end

    it "detect frequencies outside of a frequency band" do
      _(subject.between?(90, 110, :khz)).must_equal false
      _(subject.between?(90, 95, :mhz)).must_equal false
    end
  end

  describe :== do
    it "recognizes objects with identical frequency and unit as equal" do
      a = AIXM.f(123.0, :mhz)
      b = AIXM.f(123, 'MHZ')
      _(a).must_equal b
    end

    it "recognizes objects with different frequency or unit as unequal" do
      a = AIXM.f(123.35, :mhz)
      b = AIXM.f(123.35, :khz)
      _(a).wont_equal b
    end

    it "recognizes objects of different class as unequal" do
      a = AIXM.f(123.35, :mhz)
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

  describe :zero? do
    it "returns true for zero frequency" do
      _(subject.tap { _1.freq = 0 }).must_be :zero?
    end

    it "returns false for non-zero frequency" do
      _(subject.tap { _1.freq = 1 }).wont_be :zero?
    end
  end

  describe :voice? do
    let :frequencies_25 do
      118.0.step(by: 0.025, to: 136.975).to_a
    end

    let :frequencies_833 do
      frequencies_25.map { |f| [(f+0.005).round(3), (f+0.01).round(3), (f+0.015).round(3)] }.flatten
    end

    context "25 kHz voice channel separation" do
      before do
        AIXM.config.voice_channel_separation = 25
      end

      it "returns true for all valid frequencies with 25 kHz spacing" do
        frequencies_25.each do |frequency|
          _(AIXM.f(frequency, :mhz)).must_be :voice_25?
        end
      end

      it "returns false for valid frequencies with 8.33 kHz spacing" do
        frequencies_833.each do |frequency|
          _(AIXM.f(frequency, :mhz)).wont_be :voice_25?
        end
      end

      it "returns false for out of airband and out of raster frequencies" do
        [117, 137, 118.001, 136.989, 118.0000000000001].each do |frequency|
          _(AIXM.f(frequency, :mhz)).wont_be :voice_25?
        end
      end

      it "returns false for non-MHz frequencies" do
        %i(khz ghz).each do |band|
          _(AIXM.f(118, band)).wont_be :voice_25?
        end
      end
    end

    context "8.33 kHz voice channel separation" do
      before do
        AIXM.config.voice_channel_separation = 833
      end

      it "returns true for all valid frequencies with 8.33 kHz spacing" do
        frequencies_833.each do |frequency|
          _(AIXM.f(frequency, :mhz)).must_be :voice_833?
        end
      end

      it "returns false for valid frequencies with 25 kHz spacing" do
        frequencies_25.each do |frequency|
          _(AIXM.f(frequency, :mhz)).wont_be :voice_833?
        end
      end

      it "returns false for out of airband and out of raster frequencies" do
        [117, 137, 118.001, 136.989, 118.0000000000001].each do |frequency|
          _(AIXM.f(frequency, :mhz)).wont_be :voice_833?
        end
      end

      it "returns false for non-MHz frequencies" do
        %i(khz ghz).each do |band|
          _(AIXM.f(118, band)).wont_be :voice_833?
        end
      end
    end

    context "any voice channel separation" do
      before do
        AIXM.config.voice_channel_separation = :any
      end

      it "returns true for all valid frequencies with 25 or 8.33 kHz spacing" do
        (frequencies_25 + frequencies_833).each do |frequency|
          _(AIXM.f(frequency, :mhz)).must_be :voice?
        end
      end

      it "returns false for out of airband and out of raster frequencies" do
        [117, 137, 118.001, 136.989, 118.0000000000001].each do |frequency|
          _(AIXM.f(frequency, :mhz)).wont_be :voice?
        end
      end

      it "returns false for non-MHz frequencies" do
        %i(khz ghz).each do |band|
          _(AIXM.f(118, band)).wont_be :voice?
        end
      end
    end

    context "unknown voice channel separation" do
      before do
        AIXM.config.voice_channel_separation = 123
      end

      it "fails to examine any non-MHz frequency" do
        _{ AIXM.f(118, :mhz).voice? }.must_raise ArgumentError
      end

      it "returns fals for non-MHz frequencies" do
        %i(khz ghz).each do |band|
          _(AIXM.f(118, band)).wont_be :voice?
        end
      end
    end
  end
end
