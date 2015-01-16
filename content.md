web semantica lattes
http://lmpl.cnpq.br/lmpl/ 

##VIEW

* http://www.visualisingdata.com/
* http://www.visualisingdata.com/index.php/resources/
* http://www.visualisingdata.com/index.php/references/
* http://www.visualizing.org/
* (Beautiful Visualization Book)[http://it-ebooks.info/book/283/)

Dica para percusos no mapa

* air traffic routes
* flight path
* animating flight paths
* Direct Flights with Connections
* create flight path map d3
* Direct Flight Routes
* traffic flow

###MAPA

density points or heatmap google maps
* https://developers.google.com/maps/documentation/javascript/examples/layer-heatmap
* http://www.joyofdata.de/blog/interactive-heatmaps-with-google-maps-api/

D3
* http://ramblings.mcpher.com/Home/excelquirks/d3/flights
* http://xliberation.com/googlecharts/d3flights.html
* http://mbostock.github.io/d3/talk/20111116/airports.html
* http://techslides.com/map-direct-flights-with-d3/
* http://mbostock.github.io/d3/talk/20111116/airports.html
* https://github.com/mapmeld/flightmap
* http://techslides.com/demos/d3/direct-flights.html
* http://www.tnoda.com/blog/2014-04-02

Mapbox
* https://www.mapbox.com/mapbox-studio/#darwin
* https://www.mapbox.com/mapbox.js/example/v1.0.0/
* https://www.mapbox.com/mapbox.js/example/v1.0.0/animating-flight-paths/

CartoDB
* http://cartodb.com/tour/
* https://lucachaves.cartodb.com/

Mapbox vs CartoDB
* http://www.phase2technology.com/blog/open-source-tool-sets-for-creating-high-density-maps/

Leaflet
* http://leafletjs.com/
* https://www.mapbox.com/mapbox.js/example/v1.0.0/plain-leaflet/

* http://www.morethanamap.com/
* http://www.morethanamap.com/demos/visualization/flights

* http://rackpull.com/web-development/scrolling-map-animation/
* http://www.amcharts.com/demos/flight-routes-map/

* http://ramblings.mcpher.com/Home/excelquirks/getmaps/mapping/flight
* http://spatial.ly/2013/05/great-world-flight-paths-map/

* https://developers.google.com/maps/documentation/javascript/examples/polyline-simple
* http://gis.stackexchange.com/questions/62432/how-to-create-a-visualisation-of-the-worlds-aeronautical-flight-paths
* http://www.arcgis.com/home/webmap/viewer.html?webmap=abe4516f02af466db1f7c6376d485b85

* http://openflights.org/data.html
* http://planefinder.net/

http://www.visualisingdata.com/index.php/2012/02/bio-diaspora-visualising-interactions-between-populations-and-travel/

###Flight Patterns
* http://www.aaronkoblin.com/work/flightpatterns/
* http://www.ted.com/talks/aaron_koblin?language=en
* http://www.citylab.com/commute/2012/05/visualizing-day-flight-paths-us/2072/
* http://www.wired.com/2014/03/plane-viz/

#####Charting culture
Publicado na Nature
* http://cultsci.net/
* https://www.youtube.com/watch?v=4gIhRkCcD4U&feature=youtu.be


#####Counties Blue and Red, Moving Right and Left
http://www.nytimes.com/interactive/2012/11/11/sunday-review/counties-moving.html?_r=1&

tableau
* http://kb.tableausoftware.com/articles/knowledgebase/using-path-shelf-pattern-analysis
* http://www.tableausoftware.com/support/manuals/quickstart
* http://community.tableausoftware.com/message/123829
* http://sciolisticramblings.wordpress.com/2013/11/15/flights-of-fancy/
* http://public.tableausoftware.com/download/workbooks/OpenFlightsDataExplorer?format=html




https://www.ruby-toolbox.com/categories/geocoding___maps

geocoder
* http://www.rahuljiresal.com/2014/02/reverse-geocode-coordinates-in-ruby/
* http://www.bing.com/maps/?FORM=Z9LH3
* http://www.openstreetmap.org/

API MAPA
geokit
* https://github.com/geokit/geokit
google maps
* https://developers.google.com/api-client-library/ruby/start/get_started




  Location.offset(4999).limit(1000).each{|l|
  Location.where(latitude:nil).each{|l|
    # if(l.address != '' && l.city != nil && l.country != nil)
      l.valid?
      puts l.address
      puts l.position
      l.save
    # end
  }



  locations = University.find_by_sql("SELECT universities.name FROM public.universities, public.locations WHERE universities.location_id = locations.id AND locations.country = '' AND locations.city = ''").map{|u|

  locations = University.find_by_sql("SELECT universities.name FROM public.universities, public.locations WHERE universities.location_id = locations.id AND locations.latitude IS NULL AND locations.longitude IS NULL")[0..100].map{|u|
    g = Geocoder.search(u.name)
    if !g.first.nil?
      {
        "uni"=>u.name,
        "address" => g.first.data['address'],
        "latlog" => "#{g.first.data['lat']}, #{g.first.data['lon']}"
      }
    else
      nil
    end
  }
  puts JSON.pretty_generate locations



  locations = Person.all[0..20].map{|p|
    p.degrees.map{|d|
      l = d.course.university.location
      puts d.name
      puts d.course.university.name
      puts d.course.university.location.address
      g = nil
      if(l.city.nil? || l.country.nil?)
        g = Geocoder.search("#{d.course.university.name} #{l.city} #{l.country}")
      end
      (g.first != nil)?
        {"#{d.name}-#{d.course.university.name}"=>g.first.data['address'],"latlog"=>"#{g.first.data['lat']}, #{g.first.data['lon']}"}:
        nil
    }
  }
  puts JSON.pretty_generate locations

  locations = Person.all[0..20].map{|p|
    next if p.work.nil?
    puts p.work.organ
    l = p.work.university.location
    puts l.address
    g = nil
    if(l.city.nil? || l.country.nil?)
      g = Geocoder.search("#{d.course.university.name} #{l.city} #{l.country}")
    else
      next
    end
    (!g.first.nil?)?
      {"#{d.organ}"=>g.first.data['address'],"latlog"=>"#{g.first.data['lat']}, #{g.first.data['lon']}"}:
      nil
  }
  puts JSON.pretty_generate locations


  locations = Person.all[0..-1].map{|p|
    next if p.born.nil?
    l = p.born
    l.address
  }
  puts JSON.pretty_generate locations