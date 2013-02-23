class CreateNews < ActiveRecord::Migration
  def up
    create_table(:news) do |t|
      t.integer    :user_id, :null => false
      t.integer    :feed_id, :null => false
      t.string     :title
      t.string     :description
      t.string     :url
      t.boolean    :read
      t.datetime   :date
    end
  end

  def down
    drop_table :news
  end
end