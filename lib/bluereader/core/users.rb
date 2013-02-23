require 'digest/sha1'
require 'lib/bluereader/core/categories'
require 'lib/bluereader/core/settings'

module Bluereader
  class User < ActiveRecord::Base
    has_many :categories, :dependent => :destroy
    has_many :news, :dependent => :destroy
    has_many :settings, :dependent => :destroy

    class << self
      def login(username, password)
        encrypted_password = Digest::SHA1.hexdigest(password)

        if exists?(:username => username, :encrypted_password => encrypted_password)
          user_id = id_from_username(username)
          update(user_id, :logged_in_at => Time.now.to_i, :logged_out_at => 0)
          true
        else
          false
        end
      end

      def logout
        update(current_user.id, :logged_out_at => Time.now.to_i)
      end

      def validate_create_account(username, password, full_name)
        if username.empty? or password.empty? or full_name.empty?
          validation_message = 'Please fill in all the fields.'
        elsif exists?(:username => username)
          validation_message = 'This username is already in use.'
        elsif username !~ /^\w+$/
          validation_message = 'Username should contain only letters, numbers and underscores.'
        end

        validation_message or ''
      end

      def create_account(username, password, full_name)
        encrypted_password = Digest::SHA1.hexdigest(password)
        create(:username => username, :encrypted_password => encrypted_password,
               :full_name => full_name, :logged_in_at => Time.now.to_i, :logged_out_at => 0)

        Category.add_category('General')
        Setting.set_delete_after_days(1)
      end

      def delete_account
        current_user.destroy
      end

      def current_user_id
        current_user.nil? ? 0 : Integer(current_user.id)
      end

      def current_user_name
        current_user.full_name
      end

      private
      def id_from_username(username)
        user = where(:username => username).first
        user.nil? ? 0 : user.id
      end

      def current_user
        where(:logged_out_at => 0).first
      end
    end
  end
end