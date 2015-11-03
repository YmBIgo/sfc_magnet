class Idea < ActiveRecord::Base
  # association
  belongs_to :user
  belongs_to :type

  validates_presence_of :user_id, :name, :outline, :type_id, :invention

  has_attached_file :invention,
                    :styles => {
                        :thumb  => "50x50",
                        :medium => "100x100",
                        :large => "200x200"
                    },
                    :storage => :s3,
                    :s3_permissions => :private,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension"

  validates_attachment_content_type :invention, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def authenticated_image_url(style)
    invention.s3_object(style).url_for(:read, :secure => true)
  end
end
