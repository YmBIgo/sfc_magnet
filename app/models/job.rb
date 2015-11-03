class Job < ActiveRecord::Base
  # association
  has_many :users
end
