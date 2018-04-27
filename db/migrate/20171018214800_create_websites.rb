class CreateWebsites < ActiveRecord::Migration[5.1]
  def change
    create_table :websites do |t|
      t.string :url
      t.string :title
      t.string :urlImage
      t.belongs_to :category, foreign_key: true

      t.timestamps
    end
  end
end
