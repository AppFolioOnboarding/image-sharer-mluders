module PageObjects
  module Images
    class ShowPage < PageObjects::Document
      path :image

      def image_url
        node.find('.img-fluid')['src']
      end

      def tags
        node.all('.exhibit__tag').map(&:text)
      end

      def click_tag!(text)
        node.click_on(text)
        window.change_to(IndexPage)
      end

      def delete
        node.click_on('Delete Image')
        yield node.driver.browser.switch_to.alert
      end

      def delete_and_confirm!
        node.click_on('Delete Image')
        node.driver.browser.switch_to.alert.accept
        window.change_to(IndexPage)
      end

      def go_back_to_index!
        node.click_on('Home')
        window.change_to(IndexPage)
      end

      def edit_tags!
        node.click_on('Edit Tags')
        window.change_to(EditPage)
      end
    end
  end
end
