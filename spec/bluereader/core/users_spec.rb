require 'spec_helper'

module Bluereader
  describe User do
    describe 'login' do
      it 'logs in an existing user' do
        user = FactoryGirl.create(:user, :logged_out_at => Time.now.to_i)
        User.login('username', 'password')

        User.find(user.id).logged_out_at.should be_zero
      end

      it 'does not login a non-existing user' do
        now = Time.now.to_i
        user = FactoryGirl.create(:user, :logged_out_at => now)
        User.login('fake_user', 'fake_password')

        User.find(user.id).logged_out_at.should eq now
      end
    end

    describe 'logout' do
      it 'logs out a user by updating the time when they logged out' do
        user = FactoryGirl.create(:user)
        User.logout

        User.find(user.id).logged_out_at.should_not be_zero
      end
    end

    describe 'validate_create_account' do
      it 'does not allow empty fields' do
        User.validate_create_account('username', '', 'John Doe').should eq 'Please fill in all the fields.'
        User.validate_create_account('', 'password', 'John Doe').should eq 'Please fill in all the fields.'
        User.validate_create_account('username', 'password', '').should eq 'Please fill in all the fields.'
      end

      it 'does check if a username is already existing' do
        FactoryGirl.create(:user)

        User.validate_create_account('username', 'whatever', 'whatever').should eq 'This username is already in use.'
      end

      it 'allows only alphanumeric characters in the username' do
        User.validate_create_account('usern@me', 'password', 'Full name').should eq 'Username should contain only letters, numbers and underscores.'
        User.validate_create_account('!@#$%^&*()', 'password', 'Name').should eq 'Username should contain only letters, numbers and underscores.'
      end

      it 'returns an empty string if the input is correct' do
        FactoryGirl.create(:user)

        User.validate_create_account('Bond', '007', 'James Bond').should be_empty
      end
    end

    describe 'create_account' do
      it 'creates the account and that account is the last one' do
        expect do
          User.create_account('username', 'password', 'Full name')
        end.to change(User, :count).by(1)
      end
    end

    describe 'delete_account' do
      it 'deletes the account from the database but only if a user is logged' do
        FactoryGirl.create(:user)
        expect do
          User.delete_account
        end.to change(User, :count).by(-1)
      end
    end

    describe 'current_user_id' do
      it 'returns 0 if no user is currently logged' do
        User.current_user_id.should be_zero
      end

      it 'returns the right id if a user is logged' do
        user = FactoryGirl.create(:user)

        User.current_user_id.should eq user.id
      end
    end
  end
end