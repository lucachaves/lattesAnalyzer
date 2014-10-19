class Work < ActiveRecord::Base
  belongs_to :person
  belongs_to :university
end
