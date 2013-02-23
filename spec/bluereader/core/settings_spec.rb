module Bluereader
  describe Setting do
    describe 'set_delete_after_days' do
      it 'sets the number of days after the old news are being deleted for a specified user' do
        user = FactoryGirl.create(:user)

        expect do
          Setting.set_delete_after_days(user.id)
        end.to change(Setting, :count).by(1)
      end
    end

    describe 'validate_update_delete_after_days' do
      it 'does not allow empty input' do
        Setting.validate_update_delete_after_days('').should eq 'Please enter a valid positive number.'
      end

      it 'does not allow not numbers to be set as delete after days' do
        Setting.validate_update_delete_after_days('asd').should eq 'Please enter a valid positive number.'
      end

      it 'allows only for positive numbers to be set as delete after days' do
        Setting.validate_update_delete_after_days(-1).should eq 'Please enter a valid positive number.'
      end

      it 'returns an empty string if the input is valid' do
        Setting.validate_update_delete_after_days(7).should be_empty
      end
    end

    describe 'update_delete_after_days' do
      it 'updates the number of days after we delete the news for the currently logged user' do
        logged_user = FactoryGirl.create(:user)
        setting = FactoryGirl.create(:setting, :user_id => logged_user.id)
        Setting.update_delete_after_days(15)

        Setting.find(setting.id).delete_after_days.should eq 15
      end
    end

    describe 'get_delete_after_days' do
      it 'returns the number of days we store the news for the currently logged user' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:setting, :user_id => logged_user.id, :delete_after_days => 123)

        Setting.get_delete_after_days.should eq 123
      end
    end

  end
end