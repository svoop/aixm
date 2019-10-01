describe nil do

  it "fails on invalid values" do
    _([:foobar, 123]).wont_be_written_to subject, :organisation
  end

  it "accepts valid values" do
    _([AIXM::Factory.organisation]).must_be_written_to subject, :organisation
  end

end
