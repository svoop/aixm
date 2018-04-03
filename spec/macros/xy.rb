describe nil do

  it "fails on invalid values" do
    -> { subject.xy = 123 }.must_raise ArgumentError
  end

  it "accepts valid values" do
    subject.tap { |s| s.xy = AIXM::Factory.xy }.xy.must_equal AIXM::Factory.xy
  end

end
