class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.text :url, null: false
      t.text :title, null: false

      t.timestamps
    end
  end
end
