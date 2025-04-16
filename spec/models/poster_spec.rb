require 'rails_helper'

RSpec.describe Poster, type: :model do
  describe "validations - presence" do
    
    subject { Poster.new(name: 'Life') }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:vintage) }
  end

  describe "validations - uniqueness" do
    it { should validate_uniqueness_of(:name) }
  end

    
  describe "validations - only integer" do
    it { should validate_numericality_of(:year).only_integer }
  end
end
