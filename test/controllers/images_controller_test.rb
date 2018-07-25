require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image = Image.create!(
      url: 'http://abc.png',
      title: 'hello',
      created_at: Time.zone.now - 5.minutes
    )
  end

  def test_index
    Image.create!(
      url: 'http://xyz.png',
      title: 'howdy',
      created_at: Time.zone.now
    )

    get images_path

    assert_response :ok
    assert_select '#add-image'
    assert_select 'img', count: 2

    # Ensure that images are ordered by creation date, descending
    assert_select 'li:nth-of-type(1)' do
      assert_select 'img[src=?]', 'http://xyz.png'
    end

    assert_select 'li:nth-of-type(2)' do
      assert_select 'img[src=?]', 'http://abc.png'
    end
  end

  def test_index__no_image
    Image.destroy_all

    get images_path

    assert_response :ok
    assert_select 'img', count: 0
  end

  def test_show
    image2 = Image.create!(url: 'http://abc.png', title: 'test title')
    get image_path(image2)

    assert_response :ok
    assert_select '#image-title', text: 'test title'
    assert_select 'img[src=?]', 'http://abc.png'
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
        'title' => 'AppFolio logo'
      }
    }

    assert_difference 'Image.count', 1 do
      post images_path, params: params
    end

    image = Image.last
    assert_redirected_to image_path(image)
    assert_equal 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png', image.url
    assert_equal 'AppFolio logo', image.title

    follow_redirect!
    assert_select '.notice', 'The image has been added.'
  end

  def test_create__invalid
    params = {
      'image' => {
        'url' => 'https://www.betterbuys.com/wp-content/uploads/2016/05/AppFolio.png',
        'title' => ''
      }
    }

    assert_no_difference 'Image.count' do
      post images_path, params: params
    end

    assert_response :unprocessable_entity
    assert_select 'form[action="/images"]'
  end
end
