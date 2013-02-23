require 'spec_helper'

module Bluereader
  describe Category do
    describe 'validate_add_category' do
      it 'does not allow a category with an empty name to be added' do
        Category.validate_add_category('').should eq "Category name can't be empty."
      end

      it 'does not add a category with the same name more than once' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:category, :name => 'Sports', :user_id => logged_user.id)

        Category.validate_add_category('Sports').should eq 'You already have a category with the same name.'
      end

      it 'returns an empty string if the category is valid' do
        FactoryGirl.create(:user)

        Category.validate_add_category('Sports').should be_empty
      end
    end

    describe 'add_category' do
      it 'adds the category to the currently logged user' do
        FactoryGirl.create(:user)

        expect do
          Category.add_category('category_name')
        end.to change(Category, :count).by(1)
      end
    end

    describe 'deletes_category' do
      it 'deletes a category that belongs to the currently logged user' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:category, :user_id => logged_user.id, :name => 'General')
        category = FactoryGirl.create(:category, :user_id => logged_user.id)

        expect do
          Category.delete_category(category.id)
        end.to change(Category, :count).by(-1)
      end
    end

    describe 'current_user_categories' do
      it 'returns only the General category if the user has not added any categories' do
        logged_user = FactoryGirl.create(:user)
        general_category = FactoryGirl.create(:category, :name => 'General', :user_id => logged_user.id)

        Category.current_user_categories.should eq({general_category.id => 'General'})
      end

      it 'returns a hash of the categories of the current user' do
        logged_user = FactoryGirl.create(:user, :username => 'username-1')

        general_category = FactoryGirl.create(:category, :name => 'General', :user_id => logged_user.id)
        milan_category = FactoryGirl.create(:category, :name => 'Milan', :user_id => logged_user.id)
        barca_category = FactoryGirl.create(:category, :name => 'Barcelona', :user_id => logged_user.id)

        Category.current_user_categories.should eq({general_category.id => 'General',
                                                    milan_category.id => 'Milan',
                                                    barca_category.id => 'Barcelona'})

      end
    end

    describe 'general_category_id' do
      it 'returns the id of the General category for the currently logged user' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:category, :name => 'General', :user_id => logged_user.id, :id => 123)

        Category.general_category_id.should eq 123
      end
    end

    describe 'id_from_name' do
      it 'returns the id a given category for the currently logged user by its name' do
        logged_user = FactoryGirl.create(:user)
        FactoryGirl.create(:category, :id => 123, :user_id => logged_user.id, :name => 'Sports')
        FactoryGirl.create(:category, :id => 10, :user_id => logged_user.id + 100, :name => 'Sports')

        Category.id_from_name('Sports').should eq 123
      end
    end
  end
end