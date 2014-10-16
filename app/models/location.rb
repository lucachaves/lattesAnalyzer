class Location < ActiveRecord::Base
	has_many :universities
	has_many :people
end
