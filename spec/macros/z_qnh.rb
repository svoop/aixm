describe nil do

  it "fails on invalid values" do
    [:foobar, 123, AIXM.z(123, :qfe)].wont_be_written_to subject, :z
  end

  it "accepts valid values" do
    [AIXM.z(123, :qnh)].must_be_written_to subject, :z
  end

end
