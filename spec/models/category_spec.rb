
require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it 'is valid with a unique name' do
      category = Category.new(name: 'Furniture')
      expect(category).to be_valid
    end

    it 'is invalid without a name' do
      category = Category.new(name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a duplicate name' do
      Category.create!(name: 'Electronics')
      duplicate_category = Category.new(name: 'Electronics')
      expect(duplicate_category).not_to be_valid
      expect(duplicate_category.errors[:name]).to include('has already been taken')
    end
  end
end
