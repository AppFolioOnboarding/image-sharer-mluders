require 'flow_test_helper'

class ImagesCrudTest < FlowTestCase
  def test_add_an_image
    images_index_page = PageObjects::Images::IndexPage.visit

    new_image_page = images_index_page.add_new_image!

    tags = %w[foo bar]
    url = 'https://media3.giphy.com/media/EldfH1VJdbrwY/200.gif'
    new_image_page.url.set('invalid')
    new_image_page.title.set('A random title')
    new_image_page = new_image_page.create_image!.as_a(PageObjects::Images::NewPage)

    assert_text '.image_url.invalid-feedback', 'Url is not valid.'
    assert_text '.image_tag_list.invalid-feedback', "Tag list can't be blank"

    new_image_page.url.set(url)
    new_image_page.tag_list.set(tags.join(', '))
    image_show_page = new_image_page.create_image!

    assert_equal 'The image has been added.', image_show_page.flash_message(:notice)
    assert_equal url, image_show_page.image_url
    assert_equal tags, image_show_page.tags

    images_index_page = image_show_page.go_back_to_index!
    visible_image_urls = images_index_page.images.map(&:url)
    assert_includes visible_image_urls, url
  end

  def test_delete_an_image
    cute_puppy_url = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    ugly_cat_url = 'https://vignette.wikia.nocookie.net/uncyclopedia/images/1/18/Ugly_cat.jpg'
    Image.create!([
      { url: cute_puppy_url, title: 'A cute puppy', tag_list: 'puppy, cute' },
      { url: ugly_cat_url, title: 'An ugly cat', tag_list: 'cat, ugly' }
    ])

    images_index_page = PageObjects::Images::IndexPage.visit

    assert_equal 2, images_index_page.images.count
    visible_image_urls = images_index_page.images.map(&:url)
    assert_includes visible_image_urls, ugly_cat_url
    assert_includes visible_image_urls, cute_puppy_url

    image_to_delete = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end

    image_show_page = image_to_delete.view!

    image_show_page.delete do |confirm_dialog|
      assert_equal 'Are you sure?', confirm_dialog.text
      confirm_dialog.dismiss
    end

    images_index_page = image_show_page.delete_and_confirm!

    assert_equal 'The image has been deleted.', images_index_page.flash_message(:notice)
    assert_equal 1, images_index_page.images.count
    visible_image_urls = images_index_page.images.map(&:url)
    assert_not_includes visible_image_urls, ugly_cat_url
    assert_includes visible_image_urls, cute_puppy_url
  end

  def test_view_images_associated_with_a_tag
    puppy_url1 = 'http://www.pawderosa.com/images/puppies.jpg'
    puppy_url2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    cat_url = 'https://vignette.wikia.nocookie.net/uncyclopedia/images/1/18/Ugly_cat.jpg'
    Image.create!([
      { url: puppy_url1, title: 'Puppy 1', tag_list: 'cute, superman' },
      { url: puppy_url2, title: 'Puppy 2', tag_list: 'cute, puppy' },
      { url: cat_url, title: 'Ugly Cat', tag_list: 'cat, ugly' }
    ])

    images_index_page = PageObjects::Images::IndexPage.visit

    visible_image_urls = images_index_page.images.map(&:url)

    [puppy_url1, puppy_url2, cat_url].each do |url|
      assert_includes visible_image_urls, url
    end

    image_to_show = images_index_page.images.find do |image|
      image.url == puppy_url1
    end

    image_show_page = image_to_show.view!
    images_index_page = image_show_page.click_tag!('cute')

    assert_equal 2, images_index_page.images.count
    visible_image_urls = images_index_page.images.map(&:url)
    assert_not_includes visible_image_urls, cat_url

    images_index_page = images_index_page.clear_tag_filter!
    assert_equal 3, images_index_page.images.count
  end
end
