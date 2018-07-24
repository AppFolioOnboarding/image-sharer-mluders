require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  def test_image__valid
    image = Image.new(url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
                      title: 'AppFolio Logo')

    assert_predicate image, :valid?
  end

  def test_url__invalid_if_blank
    image = Image.new(url: '',
                      title: 'AppFolio Logo')

    assert_not_predicate image, :valid?
    assert_equal "can't be blank", image.errors.messages[:url].first
  end

  def test_url__invalid_if_bad_format
    image = Image.new(url: 'an invalid url / .png',
                      title: 'AppFolio Logo')

    assert_not_predicate image, :valid?
    assert_equal ' is invalid.', image.errors.messages[:url].first
  end

  def test_url__invalid_if_bad_file_type
    image = Image.new(url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.yml',
                      title: 'AppFolio Logo')

    assert_not_predicate image, :valid?
    assert_equal ' is not an acceptable type. Must be .jpeg, .png, or .gif.', image.errors.messages[:url].first
  end

  def test_title__invalid_if_blank
    image = Image.new(url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
                      title: '')

    assert_not_predicate image, :valid?
    assert_equal "can't be blank", image.errors.messages[:title].first
  end

  def test_title__invalid_if_too_short
    image = Image.new(url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
                      title: 'asdf')

    assert_not_predicate image, :valid?
    assert_equal 'is too short (minimum is 5 characters)', image.errors.messages[:title].first
  end
end
