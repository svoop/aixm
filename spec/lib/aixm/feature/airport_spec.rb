require_relative '../../../spec_helper'

describe AIXM::Feature::Airport do
  describe :initialize do
    subject do
      AIXM::Feature::Airport
    end

    it "fails on invalid arguments" do
      -> { subject.new(code: 'A') }.must_raise ArgumentError
      -> { subject.new(code: 'AB') }.must_raise ArgumentError
      -> { subject.new(code: 'ABCDE') }.must_raise ArgumentError
      -> { subject.new(code: 'AB12345') }.must_raise ArgumentError
    end

    it "upcases code" do
      subject.new(code: 'lfnt').code.must_equal 'LFNT'
    end
  end

  subject do
    AIXM::Feature::Airport.new(code: 'lftw')
  end

  describe :name= do
    it "fails on non String value" do
      -> { subject.name = nil }.must_raise ArgumentError
    end

    it "upcases and transcodes" do
      subject.tap { |s| s.name = 'Nîmes-Alès' }.name.must_equal 'NIMES-ALES'
    end
  end

  describe :xy= do
    it "fails on non AIXM::XY value" do
      -> { subject.xy = nil }.must_raise ArgumentError
    end
  end

  describe :z= do
    it "fails on non AIXM::Z value in QNH" do
      -> { subject.z = nil }.must_raise ArgumentError
      -> { subject.z = AIXM.z(123, :qfe) }.must_raise ArgumentError
    end
  end

  describe :declination= do
    it "fails on non Float value" do
      -> { subject.declination = nil }.must_raise ArgumentError
      -> { subject.declination = 181 }.must_raise ArgumentError
    end
  end

  describe :remarks= do
    it "stringifies value unless nil" do
      subject.tap { |s| s.remarks = 'foobar' }.remarks.must_equal 'foobar'
      subject.tap { |s| s.remarks = 123 }.remarks.must_equal '123'
      subject.tap { |s| s.remarks = nil }.remarks.must_be_nil
    end
  end

  describe :add_usage_limitation do
    it "fails on invalid limitation" do
      -> { subject.add_usage_limitation(:foobar) }.must_raise ArgumentError
    end

    context "without block" do
      it "accepts simple limitation" do
        subject.add_usage_limitation(:permitted)
        subject.usage_limitations.count.must_equal 1
        subject.usage_limitations.first.limitation.must_equal :permitted
      end
    end

    context "with block" do
      it "accepts complex limitation" do
        subject.add_usage_limitation(:permitted) do |permitted|
          permitted.add_condition { |c| c.aircraft = :glider }
          permitted.add_condition { |c| c.rule = :ifr }
        end
        subject.usage_limitations.count.must_equal 1
        subject.usage_limitations.first.conditions.count.must_equal 2
      end
    end
  end
end

describe AIXM::Feature::Airport::UsageLimitation do
  describe :initialize do
    subject do
      AIXM::Feature::Airport::UsageLimitation
    end

    it "fails on invalid arguments" do
      -> { subject.new(airport: 0, limitation: :permitted) }.must_raise ArgumentError
      -> { subject.new(airport: AIXM::Factory.airport, limitation: :foobar) }.must_raise ArgumentError
    end

    it "looks up limitation" do
      subject.new(airport: AIXM::Factory.airport, limitation: :RESERV).limitation.must_equal :reservation_required
    end
  end

  subject do
    AIXM::Feature::Airport::UsageLimitation.new(airport: AIXM::Factory.airport, limitation: :permitted)
  end

  describe :schedule= do
    it "fails on invalid values" do
      -> { subject.schedule = 0 }.must_raise ArgumentError
    end

    it "accepts valid values" do
      subject.tap { |s| s.schedule = AIXM::H24 }.schedule.must_equal AIXM::H24
    end
  end

  describe :remarks= do
    it "stringifies value unless nil" do
      subject.tap { |s| s.remarks = 'foobar' }.remarks.must_equal 'foobar'
      subject.tap { |s| s.remarks = 123 }.remarks.must_equal '123'
      subject.tap { |s| s.remarks = nil }.remarks.must_be_nil
    end
  end
end

describe AIXM::Feature::Airport::UsageLimitation::Condition do
  describe :initialize do
    subject do
      AIXM::Feature::Airport::UsageLimitation::Condition
    end

    it "fails on invalid arguments" do
      -> { subject.new(usage_limitation: 0) }.must_raise ArgumentError
    end
  end

  subject do
    usage_limitation = AIXM::Feature::Airport::UsageLimitation.new(airport: AIXM::Factory.airport, limitation: :permitted)
    AIXM::Feature::Airport::UsageLimitation::Condition.new(usage_limitation: usage_limitation)
  end

  describe :aircraft= do
    it "fails on invalid values" do
      -> { subject.aircraft = :foobar }.must_raise ArgumentError
    end

    it "looks up aircraft" do
      subject.tap { |s| s.aircraft = :E }.aircraft.must_equal :glider
    end
  end

  describe :rule= do
    it "fails on invalid values" do
      -> { subject.rule = :foobar }.must_raise ArgumentError
    end

    it "looks up rule" do
      subject.tap { |s| s.rule = :IV }.rule.must_equal :ifr_and_vfr
    end
  end

  describe :realm= do
    it "fails on invalid values" do
      -> { subject.realm = :foobar }.must_raise ArgumentError
    end

    it "looks up realm" do
      subject.tap { |s| s.realm = :MIL }.realm.must_equal :military
    end
  end

  describe :origin= do
    it "fails on invalid values" do
      -> { subject.aircraft = :foobar }.must_raise ArgumentError
    end

    it "looks up aircraft" do
      subject.tap { |s| s.aircraft = :E }.aircraft.must_equal :glider
    end
  end

  describe :purpose= do
    it "fails on invalid values" do
      -> { subject.purpose = :foobar }.must_raise ArgumentError
    end

    it "looks up purpose" do
      subject.tap { |s| s.purpose = :TRG }.purpose.must_equal :school_or_training
    end
  end
end
