class Image < ApplicationRecord
  acts_as_taggable

  URL_REGEXP = %r/\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix

  validates :url, presence: true,
                  format: { with: URL_REGEXP, message: ' is not valid.' }
  validate :acceptable_file_extension?
  validates :title, presence: true,
                    length: { minimum: 5 }
  validates :tag_list, presence: true

  private

  def acceptable_file_extension?
    return unless errors.count.zero? # if there are other error messages, don't run this validation.

    valid = false
    %w[.jpg .jpeg .png .gif].each do |ext|
      valid = true if url.ends_with?(ext)
    end

    errors.add(:url, ' is not an acceptable type. Must be .jpg, .jpeg, .png, or .gif.') unless valid
  end
end
