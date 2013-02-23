class CreateCategories < ActiveRecord::Migration
  def up
    create_table(:categories) do |t|
      t.integer    :user_id, :null => false
      t.string     :name
    end
  end

  def down
    drop_table :categories
  end
end
