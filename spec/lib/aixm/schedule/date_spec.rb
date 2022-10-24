require_relative '../../../spec_helper'

describe AIXM::Schedule::Date do

  context 'date with year' do
    subject do
      AIXM::Factory.date
    end

    describe :initialize, :to_date do
      it "parses valid YYYY-MM-DD string" do
        _(subject.to_date).must_equal Date.parse('2002-02-20')
      end

      it "accepts a stdlib Date" do
        _(AIXM.date(Date.parse('2003-03-30')).to_date).must_equal Date.parse('2003-03-30')
      end

      it "accepts a stdlib Time" do
        _(AIXM.date(Time.new(2004, 4, 14)).to_date).must_equal Date.parse('2004-04-14')
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

    describe :at do
      subject do
        AIXM.date('2000-12-22')
      end

      it "returns self if nothing changed" do
        _(subject.at).must_be_same_as subject
      end

      it "must replace the year part" do
        _(subject.at(year: 2020).to_date).must_equal Date.parse('2020-12-22')
      end

      it "must replace the month part" do
        _(subject.at(month: 11).to_date).must_equal Date.parse('2000-11-22')
      end

      it "must replace the day part" do
        _(subject.at(day: 21).to_date).must_equal Date.parse('2000-12-21')
      end

      it "must replace the month part and wrap" do
        _(subject.at(month: 1).to_date).must_equal Date.parse('2000-01-22')
        _(subject.at(month: 1, wrap: true).to_date).must_equal Date.parse('2001-01-22')
      end

      it "must replace the day part and wrap" do
        _(subject.at(day: 1).to_date).must_equal Date.parse('2000-12-01')
        _(subject.at(day: 1, wrap: true).to_date).must_equal Date.parse('2001-01-01')
      end

      it "must replace the month and day part and wrap" do
        _(subject.at(day: 1).to_date).must_equal Date.parse('2000-12-01')
        _(subject.at(month: 1, day: 1, wrap: true).to_date).must_equal Date.parse('2001-01-01')
      end
    end

    describe :prev do
      it "returns a new object of the preceding day" do
        date = AIXM.date('2000-06-07')
        subject = date.prev
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('2000-06-06')
      end

      it "returns a new object of the preceding day across year boundaries" do
        date = AIXM.date('2001-01-01')
        subject = date.prev
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('2000-12-31')
      end
    end

    describe :next do
      it "returns a new object of the following day" do
        date = AIXM.date('2000-06-07')
        subject = date.next
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('2000-06-08')
      end

      it "returns a new object of the following day across year boundaries" do
        date = AIXM.date('2000-12-31')
        subject = date.next
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('2001-01-01')
      end
    end

    describe :- do
      it "returns the difference in days between two dates" do
        _(AIXM.date('2000-06-11') - AIXM.date('2000-06-07')).must_equal 4
      end

      it "returns the difference in days between two dates across year boundaries" do
        _(AIXM.date('2001-01-01') - AIXM.date('2000-12-31')).must_equal 1
      end
    end

    describe :to_day do
      it "returns the day object for the corresponding weekday" do
        _(AIXM.date('2000-12-28').to_day).must_equal AIXM.day(:thursday)
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
        _(subject.to_yearless.to_date).must_equal Date.parse('0000-02-20')
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

    describe :covered_by? do
      context "range of dates with year" do
        subject do
          (AIXM.date('2002-02-02')..AIXM.date('2004-04-04'))
        end

        it "returns true if wthin range" do
          %w(2002-02-02 2003-03-03 2004-04-04).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(2002-02-01 2004-04-05).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates" do
        subject do
          (AIXM.date('02-02')..AIXM.date('04-04'))
        end

        it "returns true if wthin range" do
          %w(2002-02-02 2003-03-03 2004-04-04).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(2002-02-01 2004-04-05).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates across end of year boundary" do
        subject do
          (AIXM.date('04-04')..AIXM.date('02-02'))
        end

        it "returns true if wthin range" do
          %w(2004-04-04 2008-08-08 2002-02-02).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(2004-04-03 2002-02-03).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
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
        _(subject.to_date).must_equal Date.parse('0000-02-20')
      end

      it "parses valid XXXX-MM-DD string" do
        _(AIXM.date('XXXX-03-30').to_date).must_equal Date.parse('0000-03-30')
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

    describe :at do
      subject do
        AIXM.date('12-22')
      end

      it "returns self if nothing changed" do
        _(subject.at).must_be_same_as subject
      end

      it "must replace the year part to zero" do
        _(subject.at(year: 0).to_date).must_equal Date.parse('0000-12-22')
      end

      it "ignores the year part" do
        _(subject.at(year: 2020).to_date).must_equal Date.parse('0000-12-22')
      end

      it "must replace the month part" do
        _(subject.at(month: 11).to_date).must_equal Date.parse('0000-11-22')
      end

      it "must replace the day part" do
        _(subject.at(day: 21).to_date).must_equal Date.parse('0000-12-21')
      end

      it "must replace the day part and wrap" do
        _(subject.at(day: 1).to_date).must_equal Date.parse('0000-12-01')
        _(subject.at(day: 1, wrap: true).to_date).must_equal Date.parse('0000-01-01')
      end

      it "must replace the month and day part and wrap" do
        _(subject.at(day: 1).to_date).must_equal Date.parse('0000-12-01')
        _(subject.at(month: 1, day: 1, wrap: true).to_date).must_equal Date.parse('0000-01-01')
      end
    end

    describe :prev do
      it "returns a new object of the preceding day" do
        date = AIXM.date('06-07')
        subject = date.prev
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('06-06')
      end

      it "returns a new object of the preceding day across year boundaries" do
        date = AIXM.date('01-01')
        subject = date.prev
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('12-31')
      end
    end

    describe :next do
      it "returns a new object of the following day" do
        date = AIXM.date('06-07')
        subject = date.next
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('06-08')
      end

      it "returns a new object of the following day across year boundaries" do
        date = AIXM.date('12-31')
        subject = date.next
        _(subject.object_id).wont_equal date.object_id
        _(subject).must_equal AIXM.date('01-01')
      end
    end

    describe :- do
      it "returns the difference in days between two dates" do
        _(AIXM.date('06-11') - AIXM.date('06-07')).must_equal 4
      end

      it "returns the difference in days between two dates across year boundaries" do
        _(AIXM.date('01-01') - AIXM.date('12-31')).must_equal -365
      end
    end

    describe :to_day do
      it "fails as yearless dates cannot be computed" do
        _{ AIXM.date('12-28').to_day }.must_raise RuntimeError
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

    describe :covered_by? do
      context "single date with year" do
        subject do
          AIXM.date('2002-03-04')
        end

        it "returns true if equal" do
          _(AIXM.date('2002-03-04').covered_by?(subject)).must_equal true
        end

        it "returns false unless" do
          _(AIXM.date('2022-02-03').covered_by?(subject)).must_equal false
        end
      end

      context "single yearless date" do
        subject do
          AIXM.date('03-04')
        end

        it "returns true if equal" do
          _(AIXM.date('03-04').covered_by?(subject)).must_equal true
        end

        it "returns false unless equal" do
          _(AIXM.date('02-03').covered_by?(subject)).must_equal false
        end
      end

      context "single day" do
        subject do
          AIXM.day(:monday)
        end

        it "returns true if day is equal" do
          _(AIXM.date('2000-03-06').covered_by?(subject)).must_equal true
        end

        it "returns false unless day is equal" do
          _(AIXM.date('2000-03-07').covered_by?(subject)).must_equal false
        end
      end

      context "range of dates with year" do
        subject do
          (AIXM.date('2002-02-02')..AIXM.date('2004-04-04'))
        end

        it "returns true if wthin range" do
          %w(02-02 03-03 04-04).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(02-01 04-05).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates" do
        subject do
          (AIXM.date('02-02')..AIXM.date('04-04'))
        end

        it "returns true if wthin range" do
          %w(02-02 03-03 04-04).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(02-01 04-05).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
          end
        end
      end

      context "range of yearless dates across end of year boundary" do
        subject do
          (AIXM.date('04-04')..AIXM.date('02-02'))
        end

        it "returns true if wthin range" do
          %w(04-04 08-08 02-02).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of range" do
          %w(04-03 02-03).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
          end
        end
      end

      context "range of days" do
        subject do
          (AIXM.day(:monday)..AIXM.day(:wednesday))
        end

        it "returns true if wthin day range" do
          %w(2000-03-06 2000-03-07 2000-03-08).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of day range" do
          %w(2000-03-05 2000-03-09).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
          end
        end
      end

      context "range of days across end of week boundary" do
        subject do
          (AIXM.day(:saturday)..AIXM.day(:monday))
        end

        it "returns true if wthin day range" do
          %w(2000-03-04 2000-03-05 2000-03-06).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal true
          end
        end

        it "returns false if out of day range" do
          %w(2000-03-03 2000-03-07).each do |string|
            _(AIXM.date(string).covered_by?(subject)).must_equal false
          end
        end
      end

      context "any day" do
        subject do
          AIXM::ANY_DAY
        end

        it "returns always true" do
          10.times do
            _(AIXM.date(Time.at(rand(4_000_000_000)).to_date).covered_by?(subject)).must_equal true
          end
        end
      end
    end
  end

end
