class AddSkillColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users,    :skill,    :text
  end
end
