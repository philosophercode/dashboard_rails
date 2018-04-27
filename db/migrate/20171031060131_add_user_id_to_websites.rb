class AddUserIdToWebsites < ActiveRecord::Migration[5.1]
  def change
    add_reference :websites, :user, foreign_key: true
  end
end
