describe nil do

  it "populates the mid attribute" do
    _(subject.mid).must_be :nil?
    subject.to_xml
    _(subject.mid).wont_be :nil?
  end

end
