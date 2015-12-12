class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :user_id, null: false
      t.string :name, null: false
      t.string :color
      t.timestamps null: false
    end
  end
end
