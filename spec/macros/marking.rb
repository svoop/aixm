describe nil do

  it "accepts nil value" do
    _([nil]).must_be_written_to subject, :marking
  end

  it "stringifies valid values" do
    _(subject.tap { _1.marking = 'foobar' }.marking).must_equal 'foobar'
    _(subject.tap { _1.marking = 123 }.marking).must_equal '123'
  end

end
