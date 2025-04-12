class Poster < ApplicationRecord
  
  validates :name, :description, :vintage, presence: true
  validates :name, uniqueness: true
  validates :year, numericality: { only_integer: true }
  validates :price, numericality: { only_float: true }
# Onluy-float might not even be real but only_integer was the only thing close, so it's allowed probationarily


  def self.sorting(direction)
      order(created_at: direction)
  end

  def self.filterName(name)
    where("LOWER(name) LIKE?", "%#{name}%")
  end

  def self.maxPrice(price)
    where("price <= #{price}")
  end

  def self.minPrice(price)
    where("price >= #{price}")
  end
end