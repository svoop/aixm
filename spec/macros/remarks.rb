describe :remarks= do
  it "stringifies value unless nil" do
    subject.tap { |s| s.remarks = 'foobar' }.remarks.must_equal 'foobar'
    subject.tap { |s| s.remarks = 123 }.remarks.must_equal '123'
    subject.tap { |s| s.remarks = nil }.remarks.must_be_nil
  end
end
