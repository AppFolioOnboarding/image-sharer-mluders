# rubocop:disable Metrics/ClassLength

require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Image.create!(
      url: 'http://abc.png',
      title: 'howdy',
      tag_list: ['cute'],
      created_at: Time.zone.now - 5.minutes
    )

    Image.create!(
      url: 'http://xyz.png',
      title: 'howdy',
      tag_list: ['awesome'],
      created_at: Time.zone.now
    )
  end

  def test_index
    get images_path

    assert_response :ok
    assert_select 'img', count: 2

    # Ensure that images are ordered by creation date, descending
    assert_select '.gallery__card:nth-of-type(1)' do
      assert_select 'img[src=?]', 'http://xyz.png'
    end

    assert_select '.gallery__card:nth-of-type(2)' do
      assert_select 'img[src=?]', 'http://abc.png'
    end
  end

  def test_index__no_image
    Image.destroy_all

    get images_path

    assert_response :ok
    assert_select 'img', count: 0
  end

  def test_index__with_matching_tag
    get images_path, params: { tag: 'cute' }

    assert_response :ok
    assert_select 'img', count: 1
    assert_select 'img[src=?]', 'http://abc.png'
  end

  def test_index__with_nonmatching_tag
    get images_path, params: { tag: 'bogus' }

    assert_response :ok
    assert_select 'img', count: 0
  end

  def test_show
    img = Image.create!(
      url: 'http://abc.png',
      title: 'test title',
      tag_list: %w[cute awesome]
    )

    get image_path(img)

    assert_response :ok
    assert_select '.exhibit__title', text: 'test title'
    assert_select 'img[src=?]', 'http://abc.png'

    assert_select '.exhibit__tag-container' do
      assert_select '.exhibit__tag', count: 2
      assert_select '.exhibit__tag:nth-of-type(1)[href=?]', images_path(tag: 'cute')
      assert_select '.exhibit__tag:nth-of-type(2)[href=?]', images_path(tag: 'awesome')
    end
  end

  def test_new
    get new_image_path

    assert_response :ok
    assert_select 'form[action="/images"]'
  end

  def test_create
    params = {
      'image' => {
        'url' => 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
        'title' => 'AppFolio logo',
        'tag_list' => 'cool, appfolio'
      }
    }

    assert_difference 'Image.count', 1 do
      post images_path, params: params
    end

    image = Image.last
    assert_redirected_to image_path(image)
    assert_equal 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png', image.url
    assert_equal 'AppFolio logo', image.title
    assert_equal %w[cool appfolio], image.tag_list

    follow_redirect!
    assert_select '.notice', 'The image has been added.'
  end

  def test_create__invalid_with_no_tag_list
    params = {
      'image' => {
        'url' => 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
        'title' => 'AppFolio logo'
      }
    }

    assert_no_difference 'Image.count' do
      post images_path, params: params
    end

    assert_response :unprocessable_entity

    assert_select '.image_tag_list' do
      assert_select '.invalid-feedback', "Tag list can't be blank"
    end
  end

  def test_create__invalid
    params = {
      'image' => {
        'url' => 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
        'title' => '',
        'tag_list' => 'cool, appfolio'
      }
    }

    assert_no_difference 'Image.count' do
      post images_path, params: params
    end

    assert_response :unprocessable_entity
    assert_select 'form[action="/images"]'
  end

  def test_edit
    img = Image.create!(
      url: 'http://abc.png',
      title: 'test title',
      tag_list: %w[cute awesome]
    )

    get image_path(img)

    assert_response :ok
    assert_select '.exhibit__title', text: 'test title'
    assert_select 'img[src=?]', 'http://abc.png'

    assert_select '.exhibit__tag-container' do
      assert_select '.exhibit__tag', count: 2
      assert_select '.exhibit__tag:nth-of-type(1)[href=?]', images_path(tag: 'cute')
      assert_select '.exhibit__tag:nth-of-type(2)[href=?]', images_path(tag: 'awesome')
    end
  end

  def test_update__tag_list
    img = Image.create!(
      url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
      title: 'AppFolio logo',
      tag_list: 'cool, appfolio'
    )

    params = {
      'image' => {
        'tag_list' => 'whatup, hello'
      }
    }

    assert_difference 'Image.count', 0 do
      patch image_path(img), params: params
    end

    img.reload

    assert_redirected_to image_path(img.id)
    assert_equal 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png', img.url
    assert_equal 'AppFolio logo', img.title
    assert_equal %w[whatup hello], img.tag_list

    follow_redirect!
    assert_select '.notice', 'The image has been updated.'
  end

  def test_update__invalid_with_empty_tag_list
    img = Image.create!(
      url: 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
      title: 'AppFolio logo',
      tag_list: 'cool, appfolio'
    )

    params = {
      'image' => {
        'tag_list' => ''
      }
    }

    assert_no_difference 'Image.count' do
      patch image_path(img), params: params
    end

    assert_response :unprocessable_entity
    assert_select 'form.edit_image'
  end

  def test_destroy
    img = Image.create!(
      url: 'http://hello.png',
      title: 'Destroy me',
      tag_list: ['cute']
    )

    assert_difference 'Image.count', -1 do
      delete image_path(img)
      assert_redirected_to images_path
    end

    follow_redirect!
    assert_select '.notice', 'The image has been deleted.'
  end

  def test_destroy_nonexistent_image
    img = Image.create!(
      url: 'http://hello.png',
      title: 'Destroy me',
      tag_list: ['cute']
    )

    assert_difference 'Image.count', -1 do
      delete image_path(img)
    end

    delete(image_path(img)) # Attempt to destroy the image again.

    assert_response :not_found
    assert_select 'h1', "The page you were looking for doesn't exist."
  end
end
# rubocop:enable Metrics/ClassLength
