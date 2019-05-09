describe nil do

  it "accepts nil value" do
    [nil].must_be_written_to subject, :marking
  end

  it "stringifies valid values" do
    subject.tap { |s| s.marking = 'foobar' }.marking.must_equal 'foobar'
    subject.tap { |s| s.marking = 123 }.marking.must_equal '123'
  end

end
