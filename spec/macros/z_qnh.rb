describe :z= do
  it "fails on invalid values" do
    -> { subject.z = 123 }.must_raise ArgumentError
    -> { subject.z = AIXM.z(123, :qfe) }.must_raise ArgumentError
  end

  it "accepts valid values" do
    subject.tap { |s| s.z = AIXM.z(123, :qnh) }.z.must_equal AIXM.z(123, :qnh)
  end
end
