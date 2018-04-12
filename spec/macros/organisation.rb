describe nil do

  it "fails on invalid values" do
    [:foobar, 123].wont_be_written_to subject, :organisation
  end

  it "accepts valid values" do
    [AIXM::Factory.organisation].must_be_written_to subject, :organisation
  end

end
