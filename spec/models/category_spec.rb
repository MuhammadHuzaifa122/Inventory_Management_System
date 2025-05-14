
require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it 'is valid with a unique name' do
      category = build(:category, name: "Furniture")
      expect(category).to be_valid
    end

    it 'is invalid without a name' do
      category = build(:category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate name' do
      create(:category, name: 'Electronics')
      duplicate_category = build(:category, name: 'Electronics')
      expect(duplicate_category).not_to be_valid
      expect(duplicate_category.errors[:name]).to include('has already been taken')
    end
  end
end
