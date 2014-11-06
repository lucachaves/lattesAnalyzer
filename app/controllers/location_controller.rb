require 'debugger'

class LocationController < ApplicationController
  def index
  	# @locations = Location.limit(1000).select{|l|
  	@locations = Location.select{|l|
  		!l.latitude.nil?
  	}
  	@hash = Gmaps4rails.build_markers(@locations) do |location, marker|
  	  marker.lat location.latitude
  	  marker.lng location.longitude
  	end
  end

  def degrees_by_person
  	@degrees = Person.limit(10)[params[:id].to_i].degrees
  	# debugger
  	@markers = Gmaps4rails.build_markers(@degrees) do |degree, marker|
  	  marker.lat degree.course.university.location.latitude
  	  marker.lng degree.course.university.location.longitude
  	end

  	@polylines = []
  	@degrees.each do |d|
  		point = {
	  		"lat" => d.course.university.location.latitude,
	  		"lng" => d.course.university.location.longitude,
	  		"ele" => 0,
	  		"time" => 0
	  	}
  		@polylines << point
  	end
  	
  end

  def location_by_person
    
    # @person = Person.limit(100000)
    @person = Person.all
    
    range = if params[:id] == "a"
      @person[0..-1]
    else
      @person[0..params[:id].to_i]
    end

    @markers_set = []
    @polylines_set = []
    range.each{|person|
    	locations = []
      # debugger
    	locations << person.born unless person.born.nil?
    	person.degrees.each{|d|
    		locations << d.course.university.location
    	}
    	locations << person.work.university.location unless person.work.nil?

    	markers = []
    	locations.each{|l|
  	  	point = {
  	  		"lat" => l.latitude,
  	  		"lng" => l.longitude
  	  	}
  	  	markers << point
    	}

      polylines = []
    	locations.each{|l|
        point = {
          "lat" => l.latitude,
          "lng" => l.longitude,
          "ele" => 0,
    		  "time" => 0
        }
        polylines << point
    	}

      @markers_set << markers
      @polylines_set << polylines
    }
  end

end
