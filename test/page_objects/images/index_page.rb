module PageObjects
  module Images
    class IndexPage < PageObjects::Document
      path :images

      collection :images, locator: '.gallery', item_locator: '.gallery__card' do
        def view!
          node.find('.js-gallery__link').click
          window.change_to(ShowPage)
        end

        def url
          node.find('img')[:src]
        end
      end

      def add_new_image!
        node.click_on('Upload')
        window.change_to(NewPage)
      end

      def clear_tag_filter!
        node.click_on('Clear Filters')
        window.change_to(IndexPage)
      end
    end
  end
end
