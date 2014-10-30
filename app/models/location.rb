class Location < ActiveRecord::Base
	has_many :people
	has_many :universities
	geocoded_by :address
	after_validation :geocode

	def address
	  [city, uf, country].compact.join(', ')
	end

end
