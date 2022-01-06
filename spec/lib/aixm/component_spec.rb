require_relative '../../spec_helper'

describe AIXM::Component do
  subject do
    AIXM::Component.send(:new)
  end

  describe :meta do
    it "accepts any value" do
      _([:foobar, 123, Object.new]).must_be_written_to subject, :meta
    end
  end

end
