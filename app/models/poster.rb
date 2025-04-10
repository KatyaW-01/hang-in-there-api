class Poster < ApplicationRecord
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