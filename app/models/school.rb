class School < ActiveRecord::Base
  # association
  has_many :users
end
