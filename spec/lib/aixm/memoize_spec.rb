require_relative '../../spec_helper'

class Either
  include AIXM::Memoize

  def either(argument=nil, keyword: nil, &block)
    $entropy || argument || keyword || (block.call if block)
  end
  memoize :either
end

describe AIXM::Memoize do
  subject { Either.new }
  before { $entropy = nil }

  describe :method do
    it "memoizes for the duration of the block only" do
      _(subject.either(1)).must_equal 1
      AIXM::Memoize.method :either do
        _(subject.either(2)).must_equal 2
        $entropy = :not_nil
        _(subject.either(2)).must_equal 2
      end
      _(subject.either(3)).must_equal :not_nil
      $entropy = nil
      _(subject.either(3)).must_equal 3
    end

    it "memoizes nil return values" do
      AIXM::Memoize.method :add do
        _(subject.either).must_be :nil?
        $entropy = :not_nil
        _(subject.either).must_be :nil?
      end
    end

    it "memoizes per positional argument" do
      AIXM::Memoize.method :either do
        _(subject.either(1)).must_equal 1
        $entropy = :not_nil
        _(subject.either(1)).must_equal 1
      end
    end

    it "memoizes per keyword argument" do
      AIXM::Memoize.method :either do
        _(subject.either(keyword: 1)).must_equal 1
        $entropy = :not_nil
        _(subject.either(keyword: 1)).must_equal 1
      end
    end

    it "cannot memoize per block" do
      AIXM::Memoize.method :either do
        _(subject.either { 1 }).must_equal 1
        $entropy = :not_nil
        _(subject.either { 1 }).must_equal :not_nil
      end
    end

    it "memoizes on all instances" do
      another_subject = Either.new
      AIXM::Memoize.method :either do
        _(subject.either(1)).must_equal 1
        _(another_subject.either(2)).must_equal 2
        $entropy = :not_nil
        _(subject.either(1)).must_equal 1
        _(another_subject.either(2)).must_equal 2
      end
    end
  end
end
