class ChangeUserColumns < ActiveRecord::Migration
  def change
    change_column(:users, :job_id,    :integer, :default => 1)
    change_column(:users, :school_id, :integer, :default => 1)
  end
end
