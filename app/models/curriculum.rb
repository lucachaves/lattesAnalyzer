class Curriculum < ActiveRecord::Base
	has_many :updates
	has_and_belongs_to_many :knowledges
end
