class Person < ActiveRecord::Base
  belongs_to :location
  has_and_belongs_to_many :knowledges
  has_many :degrees
  has_many :orientations
  has_one :work

  def degree
  	degrees.last.course.name if degrees.length > 0 
  end

  def born
  	location
  end

end
