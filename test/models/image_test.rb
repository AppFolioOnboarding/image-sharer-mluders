require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  def test_image__valid
    image = Image.new(url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
                      title: 'AppFolio Logo',
                      tag_list: ['logo'])

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
    assert_equal ' is not valid.', image.errors.messages[:url].first
  end

  def test_url__invalid_if_bad_file_type
    image = Image.new(url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.yml',
                      title: 'AppFolio Logo')

    assert_not_predicate image, :valid?
    assert_equal ' is not an acceptable type. Must be .jpg, .jpeg, .png, or .gif.',
                 image.errors.messages[:url].first
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

  def test_tag__invalid_with_empty_tag_list
    image = Image.new(url: 'https://abc.png',
                      title: 'AppFolio Logo',
                      tag_list: [])

    assert_not_predicate image, :valid?
    assert_equal "can't be blank", image.errors.messages[:tag_list].first
  end

  def test_tag__add_tags
    image = Image.new(url: 'https://abc.png',
                      title: 'AppFolio Logo')

    image.tag_list.add('awesome')
    assert_equal ['awesome'], image.tag_list
  end

  def test_tag__find_image_with_tag
    image_a = Image.new(url: 'https://abc.png',
                        title: 'AppFolio Logo')
    image_a.tag_list.add('awesome')
    image_a.save

    image_b = Image.new(url: 'https://xyz.png',
                        title: 'AppFolio Logo')
    image_b.tag_list.add('cute')
    image_b.save

    image_c = Image.new(url: 'https://xyz.png',
                        title: 'AppFolio Logo')
    image_c.save

    results = Image.tagged_with('awesome')
    assert_equal image_a, results.first
    assert_equal 1, results.length
  end
end
