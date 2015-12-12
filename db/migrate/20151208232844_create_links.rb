class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :user_id, null: false
      t.string :name
      t.string :url, null: false
      t.timestamps null: false
    end
  end
end
