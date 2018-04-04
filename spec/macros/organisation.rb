describe nil do

  it "fails on invalid values" do
    -> { subject.organisation = 123 }.must_raise ArgumentError
  end

  it "accepts valid values" do
    subject.tap { |s| s.organisation = AIXM::Factory.organisation }.organisation.must_equal AIXM::Factory.organisation
  end

end
