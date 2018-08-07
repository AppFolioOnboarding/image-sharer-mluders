module PageObjects
  module Images
    class NewPage < PageObjects::Document
      path :new_image
      path :images

      form_for :image do
        element :url
        element :title
        element :tag_list
      end

      def create_image!
        node.click_on('Upload Image')
        window.change_to(ShowPage, NewPage)
      end
    end
  end
end
