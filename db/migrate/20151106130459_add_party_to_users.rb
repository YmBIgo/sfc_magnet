class AddPartyToUsers < ActiveRecord::Migration
  def change
    add_column :users,    :party,    :string
  end
end