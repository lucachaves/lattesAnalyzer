class University < ActiveRecord::Base
  belongs_to :location
  has_many :courses
end
