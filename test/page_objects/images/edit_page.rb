module PageObjects
  module Images
    class EditPage < PageObjects::Document
      path :edit_image
      path :image

      form_for :image do
        element :tag_list
      end

      def image_url
        node.find('.img-fluid')['src']
      end

      def update_tag_list!
        node.click_on('Save Tags')
        window.change_to(EditPage)
      end
    end
  end
end
