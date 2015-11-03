class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # association
  belongs_to :school
  belongs_to :job
  has_many   :ideas

  has_attached_file :avatar,
                    :styles => {
                        :thumb  => "50x50",
                        :medium => "100x100",
                        :large => "200x200"
                    },
                    :storage => :s3,
                    :s3_permissions => :private,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension"

  validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  def authenticated_image_url(style)
    avatar.s3_object(style).url_for(:read, :secure => true)
  end

  def full_profile?
    family_name? && first_name? && job_id? && school_id? && avatar?
  end

  def name
    "#{family_name}#{first_name}"
  end

end
