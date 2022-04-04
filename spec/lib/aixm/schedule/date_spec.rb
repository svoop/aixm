require_relative '../../../spec_helper'

describe AIXM::Schedule::Date do

  context 'date with year' do
    subject do
      AIXM::Factory.date
    end

    describe :initialize, :to_date do
      it "parses valid YYY-MM-DD string" do
        _(subject.to_date).must_equal Date.parse('2002-02-20')
      end

      it "accepts a stdlib Date" do
        _(AIXM.date(Date.parse('2003-03-30')).to_date).must_equal Date.parse('2003-03-30')
      end

      it "fails on invalid string" do
        _{ AIXM.date('2002-14-20') }.must_raise ArgumentError
      end
    end

    describe :to_s do
      it "returns YYYY-MM-DD by default" do
        _(subject.to_s).must_equal '2002-02-20'
        _(AIXM::Factory.yearless_date.to_s).must_equal 'XXXX-02-20'
      end

      it "applies given format" do
        _(subject.to_s('%Y')).must_equal '2002'
      end
    end

    describe :comparable_to? do
      it "returns true when compared to date with year" do
        _(subject.comparable_to?(AIXM::Factory.date)).must_equal true
      end

      it "returns false otherwise" do
        _(subject.comparable_to?(AIXM::Factory.yearless_date)).must_equal false
        _(subject.comparable_to?(:foobar)).must_equal false
      end
    end

    describe :<=> do
      it "returns -1 if other is later" do
        _(subject <=> AIXM.date('2003-03-03')).must_equal(-1)
      end

      it "returns 0 if other is equal" do
        _(subject <=> subject).must_equal 0
      end

      it "returns 1 if other is earlier" do
        _(subject <=> AIXM.date('2001-01-01')).must_equal 1
      end

      it "fails if other is a yearless date" do
        _{ subject <=> AIXM.date('01-01') }.must_raise RuntimeError
      end
    end

    describe :yearless? do
      it "returns false" do
        _(subject).wont_be :yearless?
      end
    end

    describe :to_yearless do
      it "returns yearless duplicate" do
        _(subject.to_yearless.to_date).must_equal Date.parse('-8888-02-20')
      end
    end

    describe :year do
      it "returns the year part" do
        _(subject.year).must_equal 2002
      end
    end

    describe :month do
      it "returns the month part" do
        _(subject.month).must_equal 2
      end
    end

    describe :day do
      it "returns the day of month part" do
        _(subject.day).must_equal 20
      end
    end

    describe :in? do
      context "range of dates with year" do
        subject do
          (AIXM.date('2002-02-02')..AIXM.date('2004-04-04'))
        end

        it "returns true if wthin range" do
          %w(2002-02-02 2003-03-03 2004-04-04).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(2002-02-01 2004-04-05).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates" do
        subject do
          (AIXM.date('02-02')..AIXM.date('04-04'))
        end

        it "returns true if wthin range" do
          %w(2002-02-02 2003-03-03 2004-04-04).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(2002-02-01 2004-04-05).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates across end of year boundary" do
        subject do
          (AIXM.date('04-04')..AIXM.date('02-02'))
        end

        it "returns true if wthin range" do
          %w(2004-04-04 2008-08-08 2002-02-02).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(2004-04-03 2002-02-03).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal false
          end
        end
      end
    end
  end

  context 'yearless date' do
    subject do
      AIXM::Factory.yearless_date
    end

    describe :initialize, :to_date do
      it "parses valid MM-DD string" do
        _(subject.to_date).must_equal Date.parse('-8888-02-20')
      end

      it "fails on invalid string" do
        _{ AIXM.date('14-20') }.must_raise ArgumentError
      end
    end

    describe :to_s do
      it "returns XXXX-MM-DD" do
        _(subject.to_s).must_equal 'XXXX-02-20'
      end
    end

    describe :comparable_to? do
      it "returns true when compared to yearless date" do
        _(subject.comparable_to?(AIXM::Factory.yearless_date)).must_equal true
      end

      it "returns false otherwise" do
        _(subject.comparable_to?(AIXM::Factory.date)).must_equal false
        _(subject.comparable_to?(:foobar)).must_equal false
      end
    end

    describe :<=> do
      it "returns -1 if other is later" do
        _(subject <=> AIXM.date('03-03')).must_equal(-1)
      end

      it "returns 0 if other is equal" do
        _(subject <=> subject).must_equal 0
      end

      it "returns 1 if other is earlier" do
        _(subject <=> AIXM.date('01-01')).must_equal 1
      end

      it "fails if other is a date with year" do
        _{ subject <=> AIXM.date('2001-01-01') }.must_raise RuntimeError
      end
    end

    describe :yearless? do
      it "returns true" do
        _(subject).must_be :yearless?
      end
    end

    describe :to_yearless do
      it "returns self" do
        _(subject.to_yearless).must_equal subject
      end
    end

    describe :year do
      it "returns always nil" do
        _(subject.year).must_be :nil?
      end
    end

    describe :month do
      it "returns the month part" do
        _(subject.month).must_equal 2
      end
    end

    describe :day do
      it "returns the day of month part" do
        _(subject.day).must_equal 20
      end
    end

    describe :in? do
      context "range of dates with year" do
        subject do
          (AIXM.date('2002-02-02')..AIXM.date('2004-04-04'))
        end

        it "returns true if wthin range" do
          %w(02-02 03-03 04-04).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(02-01 04-05).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates" do
        subject do
          (AIXM.date('02-02')..AIXM.date('04-04'))
        end

        it "returns true if wthin range" do
          %w(02-02 03-03 04-04).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(02-01 04-05).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates across end of year boundary" do
        subject do
          (AIXM.date('04-04')..AIXM.date('02-02'))
        end

        it "returns true if wthin range" do
          %w(04-04 08-08 02-02).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(04-03 02-03).each do |string|
            _(AIXM.date(string).in?(subject)).must_equal false
          end
        end
      end
    end
  end

end
