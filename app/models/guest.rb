class Guest < ApplicationRecord
  validates :email, uniqueness: { case_sensitive: false }
end
