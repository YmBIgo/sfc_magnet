class CreateIdeas < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.string     :name
      t.text       :outline
      t.integer    :user_id
      t.boolean    :public_idea, null: false, default: true
      t.integer    :type_id

      t.timestamps null: false
    end
  end
end
