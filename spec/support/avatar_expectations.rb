module AvatarExpectations
  def resource_file(name)
    File.expand_path("../../fixtures/#{name}", __FILE__)
  end

  # Compares a generated image against a reference fixture.
  # Uses pixel-by-pixel comparison and calculates how different the images are.
  # A distortion of 0 means identical images, 1 means completely different.
  def assert_image_equality(actual_image_blob, expected_image_name, threshold = 0.1)
    expected_image_path = resource_file("#{expected_image_name}.png")

    actual_image = Magick::Image.from_blob(actual_image_blob).first
    expected_image = Magick::Image.read(expected_image_path).first

    _, distortion = actual_image.compare_channel(expected_image, Magick::MeanSquaredErrorMetric)

    unless distortion <= threshold
      puts "Image distortion: #{distortion}. Required at most #{threshold}."
    end

    expect(distortion).to be <= threshold
  end

  def assert_image_format(image, format)
    temp_file = Tempfile.new('avatarly')
    File.open(temp_file, 'wb') do |f|
      f.write image
    end

    expect(FastImage.type(temp_file)).to eql(format)
  end
end
