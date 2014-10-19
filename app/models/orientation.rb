class Orientation < ActiveRecord::Base
  belongs_to :course
  belongs_to :knowledge
  belongs_to :person
end
