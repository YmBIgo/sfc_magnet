class Idea < ActiveRecord::Base
  # association
  belongs_to :user
  belongs_to :type

    # Elasticserach
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "idea_#{Rails.env}"

  # mapping
  settings do
    mappings dynamic: 'false' do

      indexes :name,          analyzer: 'kuromoji'
      indexes :outline,       analyzer: 'kuromoji'

      indexes :created_at,     type: 'date', format: 'date_time'

      indexes :type do
        indexes :name,        analyzer: 'keyword', index: 'not_analyzed'
      end
    end
  end

  def as_indexed_json(options = {})
    attributes
      .symbolize_keys
      .slice(:name, :outline, :created_at)
      .merge(type: { name: type.name })

  end

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

  def self.search(params = {})
    keyword = params[:q]

    search_definition = Elasticsearch::DSL::Search.search{
      query{
        if keyword.present?
          multi_match{
            query keyword
            fields %w{ name outline type.name }
          }
        else
          match_all
        end
      }
    }

    __elasticsearch__.search(search_definition)
  end
end
