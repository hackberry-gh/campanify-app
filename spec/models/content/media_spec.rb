require 'spec_helper'

describe Content::Media do
  it "uploads media [jpg jpeg gif png flv mov mp3 aiff pdf]" do
    medium = Content::Media.create!(title: "test", file: File.open("#{Rails.root}/spec/files/test.jpg"))
    medium.file.should_not eq(nil)
    medium.file.url.should_not eq(nil)
  end
end
