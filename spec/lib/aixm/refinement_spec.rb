require_relative '../../spec_helper'

describe AIXM::Refinement do

  context Array do
    describe :to_digest do
      using AIXM::Refinement::Digest
      it "must digest single string" do
        %w(a).to_digest.must_equal Digest::MD5.hexdigest('a')[0, 8]
      end

      it "must digest double string" do
        %w(a b).to_digest.must_equal Digest::MD5.hexdigest('a|b')[0, 8]
      end

      it "must digest integer" do
        [5].to_digest.must_equal Digest::MD5.hexdigest('5')[0, 8]
      end

      it "must digest float" do
        [5.0].to_digest.must_equal Digest::MD5.hexdigest('5.0')[0, 8]
      end

      it "must digest boolean" do
        [true, false].to_digest.must_equal Digest::MD5.hexdigest('true|false')[0, 8]
      end

      it "must digest nil" do
        [nil].to_digest.must_equal Digest::MD5.hexdigest('')[0, 8]
      end
    end
  end

end
