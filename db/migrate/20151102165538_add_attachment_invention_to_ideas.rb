class AddAttachmentInventionToIdeas < ActiveRecord::Migration
  def self.up
    change_table :ideas do |t|
      t.attachment :invention
    end
  end

  def self.down
    remove_attachment :ideas, :invention
  end
end
