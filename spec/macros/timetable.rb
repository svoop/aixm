describe nil do

  it "fails on invalid values" do
    _([:foobar, 123]).wont_be_written_to subject, :timetable
  end

  it "accepts nil values" do
    _([nil]).must_be_written_to subject, :timetable
  end

end
