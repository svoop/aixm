describe nil do

  it "fails on invalid values" do
    [:foobar, 123].wont_be_written_to subject, :xy
  end

  it "accepts valid values" do
    [AIXM::Factory.xy].must_be_written_to subject, :xy
  end

end
