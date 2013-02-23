class CreateSettings < ActiveRecord::Migration
  def up
    create_table(:settings) do |t|
      t.integer    :user_id, :null => false
      t.integer    :delete_after_days
    end
  end

  def down
    drop_table :settings
  end
end
