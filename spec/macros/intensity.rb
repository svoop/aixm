describe nil do

  it "fails on invalid values" do
    _([:foobar, 123]).wont_be_written_to subject, :intensity
  end

  it "accepts nil value" do
    _([nil]).must_be_written_to subject, :intensity
  end

  it "looks up valid values" do
    _(subject.tap { _1.intensity = :low }.intensity).must_equal :low
    _(subject.tap { _1.intensity = 'LIM' }.intensity).must_equal :medium
  end

end
