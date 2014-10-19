class Location < ActiveRecord::Base
	has_many :people
	has_many :universities
end
