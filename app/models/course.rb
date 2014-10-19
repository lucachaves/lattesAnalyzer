class Course < ActiveRecord::Base
  belongs_to :university
  has_many :degrees
  has_many :orientations
end
