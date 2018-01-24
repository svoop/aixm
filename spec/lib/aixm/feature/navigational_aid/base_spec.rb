require_relative '../../../../spec_helper'

describe AIXM::Feature::NavigationalAid::Base do
  let :base do
    AIXM::Feature::NavigationalAid::Base
  end

  describe :initialize do
    it "won't accept invalid arguments" do
      -> { base.send(:new, id: 'id', name: 'name', xy: 0) }.must_raise ArgumentError
      -> { base.send(:new, id: 'id', name: 'name', xy: AIXM::Factory.xy, z: 0) }.must_raise ArgumentError
      -> { base.send(:new, id: 'id', name: 'name', xy: AIXM::Factory.xy, z: AIXM.z(1, :qne)) }.must_raise ArgumentError
    end

    context "downcase attributes" do
      subject do
        base.send(:new, id: 'id', name: 'name', xy: AIXM::Factory.xy)
      end

      it "upcases ID" do
        subject.id.must_equal 'ID'
      end

      it "upcases name" do
        subject.name.must_equal 'NAME'
      end
    end
  end

  describe :to_digest do
    it "must return digest of payload" do
      subject = base.send(:new, id: 'id', name: 'name', xy: AIXM::Factory.xy, z: AIXM.z(100, :qnh))
      subject.to_digest.must_equal 711143170
    end
  end

end
