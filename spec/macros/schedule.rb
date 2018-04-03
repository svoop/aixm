describe nil do

  it "fails on invalid values" do
    -> { subject.schedule = 'foobar' }.must_raise ArgumentError
  end

end
