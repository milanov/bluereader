class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string    :username,           :null => false
      t.string    :encrypted_password, :null => false
      t.string    :full_name
      t.datetime  :logged_in_at
      t.datetime  :logged_out_at
    end
  end

  def down
    drop_table :users
  end
end