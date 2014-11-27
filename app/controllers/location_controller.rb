# require 'debugger'

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
    
    @people = Person.limit(10000)
    # @people = Person.all
    
    range = if params[:id] == "a"
      @people[0..-1]
    else
      @people[params[:id].to_i..params[:id].to_i]
    end

    @markers_set = []
    @polylines_set = []
    @countries_set = []
    range.each{|person|
      @person = person
    	locations = []
      # debugger
    	# locations << @person.born unless @person.born.nil?
    	# @person.degrees.each{|d|
    	# 	locations << d.course.university.location unless d.course.university.location.nil?
    	# }
      @person.orientations.order(:year).each{|o|
        locations << o.course.university.location unless o.course.university.location.nil?
      }
    	# locations << @person.work.university.location unless @person.work.nil?

    	markers = []
      polylines = []

      locations.each{|l|
        next if l.latitude == nil
        point = {
          "lat" => l.latitude,
          "lng" => l.longitude
        }
        markers << point
        @countries_set << l.country if !l.country.nil?
      }

      unless params[:id] == "a"
        locations.each{|l|
          next if l.latitude == nil
          point = {
            "lat" => l.latitude,
            "lng" => l.longitude,
            "ele" => 0,
            "time" => 0
          }
          polylines << point
        }
      end

      @markers_set << markers
      @polylines_set << polylines
    }

    @location_by_contry = {}
    @countries_set.uniq.each{|country|
      @location_by_contry[country] = @countries_set.count(country)
    }
    @location_by_contry = @location_by_contry.sort_by{|k,v| v}
  end

end
