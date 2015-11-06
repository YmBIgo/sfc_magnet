class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # association
  belongs_to :job
  has_many   :ideas

  # Elasticserach
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "user_#{Rails.env}" # インデックス名を指定(RDBでいうデータベース)

  settings do
    mappings dynamic: 'false' do

      indexes :family_name,    analyzer: 'keyword', index: 'not_analyzed'
      indexes :first_name,     analyzer: 'keyword', index: 'not_analyzed'

      indexes :created_at,     type: 'date', format: 'date_time'

      indexes :skill,          analyzer: 'kuromoji'

      indexes :party,          analyzer: 'kuromoji'

      indexes :job do
        indexes :name, analyzer: 'keyword', index: 'not_analyzed'
      end

    end
  end

  def as_indexed_json(options = {})
    attributes
      .symbolize_keys
      .slice(:family_name, :first_name, :skill, :party, :created_at)
      .merge( job: { name: job.name })
  end

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
    family_name? && first_name? && job_id? && party? && avatar? && skill? && self_intro?
  end

  def name
    "#{family_name}#{first_name}"
  end

  def self.search(params = {})
    keyword = params[:q]
    search_definition = Elasticsearch::DSL::Search.search {
      query{
        if keyword.present?
          multi_match{
            query keyword
            fields %w{ family_name first_name skill party job.name }
          }
        else
          match_all
        end
      }
    }

    __elasticsearch__.search(search_definition)
  end

end