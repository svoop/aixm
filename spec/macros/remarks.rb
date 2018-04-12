describe nil do

  it "accepts nil value" do
    [nil].must_be_written_to subject, :remarks
  end

  it "stringifies valid values" do
    subject.tap { |s| s.remarks = 'foobar' }.remarks.must_equal 'foobar'
    subject.tap { |s| s.remarks = 123 }.remarks.must_equal '123'
  end

end
