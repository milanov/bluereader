class CreateFeeds < ActiveRecord::Migration
  def up
    create_table(:feeds) do |t|
      t.integer   :user_id,       :null => false
      t.integer   :category_id,   :null => false
      t.string    :name
      t.string    :url
    end
  end

  def down
    drop_table :feeds
  end
end
