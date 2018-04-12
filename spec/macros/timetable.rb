describe nil do

  it "fails on invalid values" do
    [:foobar, 123].wont_be_written_to subject, :timetable
  end

  it "accepts nil values" do
    [nil].must_be_written_to subject, :timetable
  end

end
