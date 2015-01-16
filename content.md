##VIEW

* http://www.visualisingdata.com/
* http://www.visualisingdata.com/index.php/resources/
* http://www.visualisingdata.com/index.php/references/
* http://www.visualizing.org/
* (Beautiful Visualization Book)[http://it-ebooks.info/book/283/)

word frequency analyze

* http://www.tapor.ca/


Dica para percusos no mapa

* air traffic routes
* flight path
* animating flight paths
* Direct Flights with Connections
* create flight path map d3
* Direct Flight Routes
* traffic flow

Flight Patterns

* http://www.aaronkoblin.com/work/flightpatterns/
* http://www.ted.com/talks/aaron_koblin?language=en
* http://www.citylab.com/commute/2012/05/visualizing-day-flight-paths-us/2072/
* http://www.wired.com/2014/03/plane-viz/

###Charting culture
Publicado na Nature
* http://cultsci.net/
* https://www.youtube.com/watch?v=4gIhRkCcD4U&feature=youtu.be


###Counties Blue and Red, Moving Right and Left
http://www.nytimes.com/interactive/2012/11/11/sunday-review/counties-moving.html?_r=1&


###API Mapa

* http://nominatim.openstreetmap.org/
* http://wiki.openstreetmap.org/wiki/Main_Page
* http://wiki.openstreetmap.org/wiki/Develop
* http://wiki.openstreetmap.org/wiki/WIWOSM
* http://wiki.openstreetmap.org/wiki/Nominatim
* http://nominatim.openstreetmap.org/search?q=highway,Kingston+University&format=json
* nominatim filter search by class???
  * http://nominatim.openstreetmap.org/search/school,cleveland,oh?format=json
  * http://nominatim.openstreetmap.org/reverse?format=json&lon=-0.2995&lat=51.4103
* http://openlayers.org/
* http://www.gisgraphy.com/


google maps: density points or heatmap 
* https://developers.google.com/api-client-library/ruby/start/get_started
* https://developers.google.com/maps/documentation/geocoding/
* https://developers.google.com/places/documentation/supported_types
* https://developers.google.com/maps/documentation/javascript/examples/layer-heatmap
* geocoder filter by kind of place???
  * http://maps.google.com/maps/api/geocode/json?address=Kingston+University&components=university:ES&sensor=false
  * http://maps.googleapis.com/maps/api/staticmap?center=Berkeley,CA&zoom=14&size=400x400&sensor=false
  * http://maps.googleapis.com/maps/api/staticmap?center=40.714728,-73.998672&zoom=14&size=400x400&sensor=false
* http://www.joyofdata.de/blog/interactive-heatmaps-with-google-maps-api/
* http://www.morethanamap.com/
* http://www.morethanamap.com/demos/visualization/flights

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
* https://www.mapbox.com/developers/api/geocoding/
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

tableau
* http://kb.tableausoftware.com/articles/knowledgebase/using-path-shelf-pattern-analysis
* http://www.tableausoftware.com/support/manuals/quickstart
* http://community.tableausoftware.com/message/123829
* http://sciolisticramblings.wordpress.com/2013/11/15/flights-of-fancy/
* http://public.tableausoftware.com/download/workbooks/OpenFlightsDataExplorer?format=html

OPEN FLIGHTS
* http://openflights.org/data.html
* http://planefinder.net/
* http://www.visualisingdata.com/index.php/2012/02/bio-diaspora-visualising-interactions-between-populations-and-travel/
* https://developers.google.com/maps/documentation/javascript/examples/polyline-simple
* http://gis.stackexchange.com/questions/62432/how-to-create-a-visualisation-of-the-worlds-aeronautical-flight-paths
* http://www.arcgis.com/home/webmap/viewer.html?webmap=abe4516f02af466db1f7c6376d485b85
* http://ramblings.mcpher.com/Home/excelquirks/getmaps/mapping/flight
* http://spatial.ly/2013/05/great-world-flight-paths-map/
* http://rackpull.com/web-development/scrolling-map-animation/
* http://www.amcharts.com/demos/flight-routes-map/



###RUBY MAPA
https://www.ruby-toolbox.com/categories/geocoding___maps

geocoder
* http://www.rahuljiresal.com/2014/02/reverse-geocode-coordinates-in-ruby/
* http://www.bing.com/maps/?FORM=Z9LH3
* http://www.openstreetmap.org/

geokit
* https://github.com/geokit/geokit

###EXIBIR INFO LOCATION

  Location.offset(4999).limit(1000).each{|l|
  Location.where(latitude:nil).each{|l|
    # if(l.address != '' && l.city != nil && l.country != nil)
      l.valid?
      puts l.address
      puts l.position
      l.save
    # end
  }

###EXIBIR UNIVERSITY COM LOCATION

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

###CONSULTAR LOCATION DE UNIVERSITY ATRAVÉS DO Geocoder

  #1
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

  #2
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

###EXIBIR NASCIMENTO

  locations = Person.all[0..-1].map{|p|
    next if p.born.nil?
    l = p.born
    l.address
  }
  puts JSON.pretty_generate locations

###INDEX KNOWLEDGE
  
  [ID 896001 : 896000/3911585 22.91% (04/12/2014 02:25:06 - day:01 11:06:03 - 06/12/2014 02:52:48)] 
  [ID 1069701 : 166201/3008085 5.53% (04/12/2014 11:00:32 - day:01 04:27:39 - 07/12/2014 19:44:45)]
  [ID 1368501 : 298801/2841885 10.51% (04/12/2014 22:53:44 - day:01 07:57:57 - 08/12/2014 02:39:29)] 
  [ID 1447701 : 79201/2543085 3.11% (05/12/2014 08:01:26 - day:01 03:00:09 - 09/12/2014 08:25:54)] 
  [ID 2203600 : 591601/2299586 25.73% (06/12/2014 12:01:13 - day:02 10:45:33 - 12/12/2014 03:07:51)] 
  [ID 2203600 : 591601/2299586 25.73% (06/12/2014 12:01:13 - day:02 10:45:33 - 12/12/2014 03:07:51)] 
  [ID 2320600 : 117001/1707986 6.85% (09/12/2014 23:45:43 - day:01 09:10:49 - 15/12/2014 13:46:33)]

###Sending logs to Graylog2 server
https://www.ruby-toolbox.com/categories/Log_Analysis
https://github.com/Graylog2/gelf-rb
http://www.graylog2.org/resources/documentation/sending/rails
http://logstash.net/docs/1.4.2/tutorials/getting-started-with-logstash
https://github.com/garethr/graylogtail
https://scoutapp.com/plugin_urls

###Tempfile & Mechanize
* http://stackoverflow.com/questions/3316043/how-do-i-download-a-remote-image-from-another-site-to-a-file-column-in-ruby-on-r
* agent.get('http://example.com/foo').save_as 'a_file_name'

###UNZIP
* http://www.markhneedham.com/blog/2008/10/02/ruby-unzipping-a-file-using-rubyzip/

###RTESSERACT & RMAGICK
https://github.com/dannnylo/rtesseract
https://github.com/gemhome/rmagick
http://superuser.com/questions/361435/i-have-compiled-imagemagick-on-my-centos-and-rmagick-wont-install

brew install imagemagick --disable-openmp
#tesseract
sudo PKG_CONFIG_PATH=/usr/local/Cellar/imagemagick/6.8.9-7/lib/pkgconfig gem install rmagick -V

###NOKOGIRI
https://github.com/sparklemotion/nokogiri/wiki/Cheat-sheet
https://gist.github.com/rstacruz/1569572
http://blog.ubiquo.me/now-on-edge-easier-relations-in-scaffold-gene/

xmldoc = Nokogiri::XML(File.read('app/helpers/lattes/0005349558315095.xml'))
xmldoc.xpath("//FORMACAO-ACADEMICA-TITULACAO").children

###SINGLETON
http://www.ruby-doc.org/stdlib-1.9.3/libdoc/singleton/rdoc/Singleton.html


###SocketError
http://stackoverflow.com/questions/12358682/rails-post-socketerror-getaddrinfo-temporary-failure-in-name-resolution-on

###Concurrency and Database Connections in RoR
Multiple Connection
FATAL: sorry, too many clients already
https://devcenter.heroku.com/articles/concurrency-and-database-connections
http://stackoverflow.com/questions/15086880/correct-setting-of-database-connection-pool-database-yml-for-single-threaded-rai

###Multiple Database
http://stackoverflow.com/questions/17311199/connecting-to-multiple-databases-in-ruby-on-rails
def connection
  ActiveRecord::Base.establish_connection("#{Rails.env}_sec".to_sym).connection
end
establish_connection "#{Rails.env}_sec".to_sym
rake db:migrate:redo VERSION=version

###rails find_or_create_by case insensitive

###GENERATOR

  rails generate model person id16:primary_key name:string lattes_updated_at:date location:references knowlegde:references --no-id

  rails generate model curriculum id16:string id10:string:uniq lattes_updated_at:date scholarship:string degree:string{2000} xml:xml xml_length:integer orientation:string{2000}
  rails generate model update lattes_updated_at:date:uniq curriculum:references
  rails generate model location city:string uf:string country:string country_abbr:string latitude:float longitude:float
  rails generate model university name:string abbr:string organ:string location:references
  rails generate model course name:string university:references
  rails generate model degree name:string title:string year:integer course:references person:references
  rails generate model person id16:string id10:string:uniq name:string scholarship:string lattes_updated_at:date location:references
  rails generate model work organ:string person:references university:references
  rails generate model knowledge major_subject:string subject:string subsection:string specialty:string
  rails generate model orientation document:string title:string kind:string formation:string year:string language:string orientation:string student:string course:references knowledge:references person:references
  rails generate migration CreateJoinTableKnowledgePeople knowledge person


  rake db:drop
  rails destroy model curriculum
  rails destroy model update
  rails destroy model location
  rails destroy model university
  rails destroy model degree
  rails destroy model person
  rails destroy model course
  rails destroy model work
  rails destroy model knowledge
  rails destroy model orientation
  rails destroy migration CreateJoinTableKnowledgePeople

  Update.destroy_all
  Work.destroy_all
  University.destroy_all
  Person.destroy_all
  Orientation.destroy_all
  Location.destroy_all
  Knowledge.destroy_all
  Degree.destroy_all
  Course.destroy_all

  How to restart id counting on a table in PostgreSQL after deleting some previous data
  ALTER SEQUENCE seq RESTART WITH 1;
  UPDATE t SET idcolumn=nextval('seq');
  ActiveRecord::Base.connection.reset_pk_sequence!('updates')
  ActiveRecord::Base.connection.reset_pk_sequence!('work')
  ActiveRecord::Base.connection.reset_pk_sequence!('universities')
  ActiveRecord::Base.connection.reset_pk_sequence!('people')
  ActiveRecord::Base.connection.reset_pk_sequence!('orientations')
  ActiveRecord::Base.connection.reset_pk_sequence!('locations')
  ActiveRecord::Base.connection.reset_pk_sequence!('knowledges')
  ActiveRecord::Base.connection.reset_pk_sequence!('degrees')
  ActiveRecord::Base.connection.reset_pk_sequence!('courses')

  rake db:reset


###GENERATE DATA

  #1
  l = Location.create city: 'jp', uf: 'pb', country: 'pb'
  l.universities.create :name => 'UFPB'
  l.universities.last.course.create :name => 'PPGI'
  l.universities.last.course.last.degree.create :name => 'DOUTORADO'
  p = Person.create :name => 'luiz'
  l.universities.last.course.last.degree.last.person = p

  p = Person.create :name => 'luiz'

  l = Location.create city: 'jp', uf: 'pb', country: 'pb'

  u = University.create :name => 'UFPB'
  u.location = l
  u.save

  c = Course.create :name => 'PPGI'
  c.university = u
  c.save

  d1 = Degree.create :name => 'DOUTORADO'
  d1.course = c
  d1.save

  d2 = Degree.create :name => 'MESTRADO'
  d2.course = c
  d2.save

  p.degrees << d1
  p.degrees << d2

  p.location = l

  p.save

  p.degrees.each{|d| puts d.course.university.name}
  p.degrees.each{|d| puts d.course.university.location.country}
  Degree.all.each{|d| puts d.course.university.name}
  Degree.all.each{|d| puts ">>> #{d.name} #{d.course.name} #{d.course.university.name} #{d.course.university.location.country}"}
  Location.all.each{|l| puts " #{l.city} #{l.uf} #{l.country}" }

##LATTES 
http://www.cnpq.br/web/guest/geral
http://lattes.cnpq.br/
http://www.cnpq.br/web/portal-lattes/outras-bases
http://www.cnpq.br/web/portal-lattes/dados-e-estatisticas
http://lmpl.cnpq.br/lmpl/


###FILTROS DO BUSCATEXTUAL
  
  Total 3900735 (10/2014)
  PQ 14339 (1[ABCD], 2)
  Outras Bolsas
  D 201984
  M 394958
  E 733707
  G 2005267
  D+G+M+G 3335916 (Resta 564819 Técn, Granduando, EM)
  
  idx_particao:0 #outros
  idx_particao:1 #doutores
  idx_nacionalidade:e
  idx_nacionalidade:b
  idx_formacao_academica:graduacao
  idx_formacao_academica:especializacao
  idx_formacao_academica:mestrado
  idx_formacao_academica:doutorado
  idx_formacao_academica:bra
  idx_grd_area_atua:"CIENCIAS_AGRARIAS"
  idx_modalidade_bolsa:1a 
  idx_modalidade_bolsa:1b 
  idx_modalidade_bolsa:1c 
  idx_modalidade_bolsa:1d 
  idx_modalidade_bolsa:2
  idx_modalidade_bolsa:(pq) #produtividade
  idx_modalidade_bolsa:gm # mestrado

  # todos
  url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=0;100&query=( +idx_nacionalidade:e) or ( +idx_nacionalidade:b)&analise=cv"
  # pq
  url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=0;10&query=( +( idx_modalidade_bolsa:1a idx_modalidade_bolsa:1b idx_modalidade_bolsa:1c idx_modalidade_bolsa:1d idx_modalidade_bolsa:2) +idx_modalidade_bolsa:(pq)  +idx_nacionalidade:e) or ( +( idx_modalidade_bolsa:1a idx_modalidade_bolsa:1b idx_modalidade_bolsa:1c idx_modalidade_bolsa:1d idx_modalidade_bolsa:2) +idx_modalidade_bolsa:(pq)  +idx_nacionalidade:b)&analise=cv"


###XML LATTES
DTD LATTES 
http://www.cnpq.br/documents/313759/b6f13489-2166-4cb4-8be5-8ab3fb5ab106
http://lmpl.cnpq.br/lmpl/index.jsp

ORIENTACOES
//ORIENTACOES-CONCLUIDAS/ORIENTACOES-CONCLUIDAS-PARA-MESTRADO
DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO
  @NATUREZA
  @TIPO
  @TITULO
  @ANO
  @IDIOMA

  DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO
    @TIPO-DE-ORIENTACAO
    @NOME-DA-INSTITUICAO
    @CODIGO-INSTITUICAO
    //INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{codigo}']/@NOME-PAIS-INSTITUICAO
    //INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{codigo}']/@SIGLA-INSTITUICAO
    //INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{codigo}']/@SIGLA-UF-INSTITUICAO
    //INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{codigo}']/@SIGLA-PAIS-INSTITUICAO
  
    @NOME-DO-CURSO
    @CODIGO-CURSO
    //INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{codigo}']/@NOME-GRANDE-AREA-DO-CONHECIMENTO
    //INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{codigo}']/@NOME-DA-AREA-DO-CONHECIMENTO
    //INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{codigo}']/@NOME-DA-SUB-AREA-DO-CONHECIMENTO
    //INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{codigo}']/@NOME-DA-ESPECIALIDADE
    //INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{codigo}']/@NIVEL-CURSO

PALAVRAS-CHAVE
SETORES-DE-ATIVIDADE
AREAS-DO-CONHECIMENTO

//DADOS-COMPLEMENTARES/ORIENTACOES-EM-ANDAMENTO/ORIENTACAO-EM-ANDAMENTO-DE-DOUTORADO
@NATUREZA
@TIPO
@TITULO
@ANO
@IDIOMA


//CURRICULO-VITAE
  /OUTRA-PRODUCAO
    /ORIENTACOES-CONCLUIDAS
      /ORIENTACOES-CONCLUIDAS-PARA-MESTRADO
        /DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS/@NATUREZA 
      /OUTRAS-ORIENTACOES-CONCLUIDAS
        /DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS/@NATUREZA 
  /DADOS-COMPLEMENTARES
    /ORIENTACOES-EM-ANDAMENTO
      /ORIENTACAO-EM-ANDAMENTO-DE-MESTRADO
        /DADOS-BASICOS-DA-ORIENTACAO-EM-ANDAMENTO-DE-MESTRADO/@NATUREZA

@NATUREZA (
  ORIENTACAO-DE-OUTRA-NATUREZA|
  INICIACAO_CIENTIFICA|
  TRABALHO_DE_CONCLUSAO_DE_CURSO_GRADUACAO
)


<!ELEMENT ORIENTACOES-CONCLUIDAS (ORIENTACOES-CONCLUIDAS-PARA-MESTRADO*, ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO*,ORIENTACOES-CONCLUIDAS-PARA-POS-DOUTORADO*, OUTRAS-ORIENTACOES-CONCLUIDAS*)>

<!ATTLIST DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS
  NATUREZA (MONOGRAFIA_DE_CONCLUSAO_DE_CURSO_APERFEICOAMENTO_E_ESPECIALIZACAO | TRABALHO_DE_CONCLUSAO_DE_CURSO_GRADUACAO | INICIACAO_CIENTIFICA | ORIENTACAO-DE-OUTRA-NATUREZA)  #IMPLIED

<!ELEMENT ORIENTACOES-EM-ANDAMENTO (ORIENTACAO-EM-ANDAMENTO-DE-MESTRADO*, ORIENTACAO-EM-ANDAMENTO-DE-DOUTORADO*,ORIENTACAO-EM-ANDAMENTO-DE-POS-DOUTORADO*, ORIENTACAO-EM-ANDAMENTO-DE-APERFEICOAMENTO-ESPECIALIZACAO*, ORIENTACAO-EM-ANDAMENTO-DE-GRADUACAO*, ORIENTACAO-EM-ANDAMENTO-DE-INICIACAO-CIENTIFICA*, OUTRAS-ORIENTACOES-EM-ANDAMENTO*)>

<!ATTLIST DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO
  NATUREZA CDATA  #IMPLIED>


###DBPEDIA

http://dbpedia.org/page/Federal_University_of_Para%C3%ADba
http://dbpedia.org/sparql
select * where {
?subject rdf:type <http://schema.org/CollegeOrUniversity>.
?subject rdfs:label ?label.
?subject 
FILTER (lang(?label) = "en")
} LIMIT 100

###FREEBASE
https://www.freebase.com/
MQL
http://mql.freebaseapps.com/index

https://www.googleapis.com/freebase/v1/search?indent=true&query=Kingston+University&filter=(all type:/education/university )
https://www.googleapis.com/freebase/v1/search?indent=true&query=john&filter=(all type:/people/person /people/person/nationality:"Canada")

https://www.freebase.com/education
https://www.freebase.com/education?schema=
https://www.freebase.com/education/university
https://www.freebase.com/education/university?schema=
http://www.freebase.com/education/university?instances=

https://www.freebase.com/organization/organization/headquarters?schema=

https://www.freebase.com/location
https://www.freebase.com/location?schema=
https://www.freebase.com/location?instances=
https://www.freebase.com/location/geocode?schema=
https://www.freebase.com/location/citytown?schema=
https://www.freebase.com/location/citytown?instances=
https://www.freebase.com/location/mailing_address?schema=
https://www.freebase.com/location/country?schema=
http://www.freebase.com/location/country?instances=
http://www.freebase.com/location/country?i18n=
http://www.freebase.com/location/country?props=
http://www.freebase.com/location/country?keys=
http://www.freebase.com/location/country?links=
'{"id":"/en/china","capital":null,"type":"/location/country"}'

http://www.freebase.com/m/05v33x
m.05v33x
ns:rdf:type    ns:education.university;
ns:type.object.name    "Federal University of Para\xedba"@en;
ns:organization.organization.headquarters    ns:m.0jk7tcg;
ns:common.topic.alias    "Federal University of Paraiba"@en;
ns:common.topic.alias    "Universidade Federal da Para\xedba"@en;
ns:common.topic.alias    "UFPB"@en;
ns:common.topic.alias    "UFPB"@pt;

m.0jk7tcg
ns:rdf:type    ns:location.location
ns:location.mailing_address.citytown    ns:m.01hy9d;

m.01hy9d
ns:rdf:type    ns:location.citytown;
ns:common.topic.alias    "Joao Pessoa"@en;
ns:type.object.name    "Jo\xe3o Pessoa"@es;
ns:location.location.containedby    ns:m.015fr;
ns:location.location.containedby    ns:m.01hdp5;

015fr
ns:type.object.type    ns:location.country;

01hdp5
ns:type.object.type    ns:location.administrative_division;



ns:rdf:type    ns:education.university;
ns:type.object.name    null;
ns:organization.organization.headquarters    null;


[{
  "id": null,
  "mid": null,
  "name": "London"
}]

[{
  "mid": null,
  "name": null,
  "type": "/education/university",
  "/organization/organization/headquarters": [{
    "/location/mailing_address/citytown": [{
      "name": null
    }]
  }]
}]

[{
  "mid": null,
  "name": null,
  "name~=": "University of Zurich",
  "/common/topic/alias~=": "Universitat Zurich",
  "type": "/education/university",
  "/organization/organization/headquarters":[{
    "/location/mailing_address/citytown": [{
      "name": null,
      "/location/location/containedby": [{
        "type": "/location/country",
        "name": null
      }],
      "/location/location/containedby": [{
        "type": "/location/administrative_division",
        "name": null
      }]
    }]
  }]
}]

https://github.com/PerfectMemory/freebase-api
https://www.freebase.com/query
http://www.freebase.com/explore
https://developers.google.com/freebase/
Topic, RDF, MQL, Search
http://wiki.freebase.com/wiki/Topic
http://wiki.freebase.com/wiki/Types
http://wiki.freebase.com/wiki/Domain
http://wiki.freebase.com/wiki/Object
/type/domain > /type/object/type > /common/topic
https://developers.google.com/freebase/v1/getting-started
https://www.freebase.com/search?query=Università di Pavia&lang=en&scoring=entity&prefixed=true&any=/common/topic
https://www.googleapis.com/freebase/v1/search?query=Università di Pavia&indent=true&lang=en&scoring=entity&prefixed=true&any=/common/topic
https://www.googleapis.com/freebase/v1/search?query=Università di Pavia&indent=true&any=/common/topic&limit=1
https://www.googleapis.com/freebase/v1/search?indent=true&query=london
https://www.googleapis.com/freebase/v1/search?indent=true&filter=(any type:/people/person)
https://www.googleapis.com/freebase/v1/mqlread?query={"id": null,"mid": "/m/04jpl","name": "London"}
https://www.googleapis.com/freebase/v1/topic/en/london
https://www.googleapis.com/freebase/v1/rdf/en/london

MQL

FreebaseAPI.session.mqlread({
  :type => '/internet/website',
  :id => '/en/github',
  :'/common/topic/official_website' => nil}
)

FreebaseAPI.session.mqlread({
  :mid => nil,
  :name => nil,
  :'name~=' => "University of Zurich",
  :type => "/education/university"
})


FreebaseAPI.session.mqlread({
  :mid => nil,
  :name => nil,
  :'name~=' => "University of Zurich",
  :type => "/education/university",
  :'/organization/organization/headquarters' => {
    :'/location/mailing_address/citytown' => {
      :name => nil
    }
  }
 })

FreebaseAPI.session.mqlread({
  :mid => nil,
  :name => nil,
  :'name~=' => "University of Zurich",
  :type => "/education/university",
  :'/organization/organization/headquarters' =>[{
    :'/location/mailing_address/citytown' => [{
      :name => nil,
      :'/location/location/containedby' => [{
        :type => "/location/country",
        :name => nil
      }],
      :'/location/location/containedby' => [{
        :type => "/location/administrative_division",
        :name => nil
      }]
    }]
  }]
})

FreebaseAPI.session.mqlread({
  :mid => nil,
  :name => nil,
  :'name~=' => "University of Zurich",
  :type => "/education/university",
  :'/organization/organization/headquarters' =>{
    :'/location/mailing_address/citytown' => {
      :name => nil,
      :'/location/location/containedby' => {
        :type => "/location/country",
        :name => nil
      },
    }
  }
})


:'name~=' => "Federal",
:'name~=' => "Paraíba",
:'name~=' => "University of Zurich",

FreebaseAPI.session.mqlread({
  :mid => nil,
  :name => nil,
  :'name~=' => "University of Zurich",
  :type => "/education/university",
  :'/organization/organization/headquarters' =>{
    :'/location/mailing_address/citytown' => {
      :name => nil,
      :'/location/location/containedby' => [{
        :type => "/location/administrative_division",
        :name => nil
      }]
    }
  }
})

FreebaseAPI.session.mqlread([{
  :mid => nil,
  :name => nil,
  :'name~=' => "Federal",
  :type => "/education/university",
  :'/organization/organization/headquarters' =>[{
    :'/location/mailing_address/citytown' => [{
      :name => nil,
      :'/location/location/containedby' => [{
        :type => "/location/country",
        :name => nil
      }],
    }]
  }]
}])

FreebaseAPI.session.mqlread([{
  :mid => nil,
  :name => nil,
  :'name~=' => "Federal",
  :type => "/education/university",
  :'/organization/organization/headquarters' =>[{
    :'/location/mailing_address/citytown' => [{
      :name => nil,
      :'/location/location/containedby' => [{
        :type => "/location/administrative_division",
        :name => nil
      }],
    }]
  }]
}])

x.map{|y| 
  [
    y["name"],
    y["/organization/organization/headquarters"][0]["/location/mailing_address/citytown"][0]["/location/location/containedby"][0]["name"]
  ]
}


[{
  "mid": null,
  "name": null,
  "name~=": "Kingston University",
  "type": "/education/university",
  "/organization/organization/headquarters":[{
    "/location/mailing_address/citytown": [{
      "name": null,
      "/location/location/containedby": [{
        "type": "/location/administrative_division",
        "name": null,
        "mid": null,
        
      }],
    }]
  }]
}]

[{
  "id": null,
  "name": null,
  "name~=": "Tunas",
  "type": "/education/university",
  "/organization/organization/headquarters": [{
    "/location/mailing_address/citytown": [{
      "name": null,
      "mid": null,
      "id": null,
      "/location/location/geolocation": [{
        "mid": null,
        "/location/geocode/latitude": null,
        "/location/geocode/longitude": null
      }]
    }],
    "/location/mailing_address/country": [{
      "name": null,
      "mid": null
    }]
  }]
}]



###[XML, DTD, XSL] -> [SQL, DB, CSV]

XML to SQL Converter

HyperJAXB
https://github.com/highsource/hyperjaxb3/
http://confluence.highsource.org/display/HJ3/Documentation
http://grepcode.com/file/repo1.maven.org/maven2/org.jvnet.hyperjaxb3/hyperjaxb3-ejb-roundtrip/0.5.6/org/jvnet/hyperjaxb3/ejb/test/
http://confluence.highsource.org/display/HJ3/Documentation
http://confluence.highsource.org/display/HJ3/Home
http://confluence.highsource.org/display/HJ3/Downloads
http://confluence.highsource.org/display/HJ3/Purchase+Order+Tutorial
http://confluence.highsource.org/display/HJ3/Generating+persistence+unit+descriptor
http://confluence.highsource.org/display/HJ3/Customization+Guide
http://confluence.highsource.org/display/HJ3/Hibernate
https://java.net/projects/hyperjaxb
https://java.net/projects/hyperjaxb2
https://java.net/projects/hyperjaxb3
https://github.com/claudemamo/hyperjaxb3-example
http://xircles.codehaus.org/projects/hyperjaxb3
https://wikis.oracle.com/display/GlassFish/Hyperjaxb3Usage
http://gerardnico.com/wiki/language/java/hyperjaxb
https://benwilcock.wordpress.com/tag/hyperjaxb3/
http://yaug.org/content/persistence-hyperjaxb3-framework
http://opensourcesoftwareandme.blogspot.com.br/2012/11/a-practical-solution-for-xml-to.html
http://www.scribd.com/doc/3031341/HyperJaxb2
https://answersresource.wordpress.com/2014/10/14/no-persistence-provider-for-entitymanager-named-persistence-xml/
mvn clean install exec:java -Dexec.mainClass="main.java.Main"
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>5.0.5</version>
    <scope>test</scope>
</dependency>
hibernate.dialect=org.hibernate.dialect.MySQLDialect
hibernate.connection.driver_class=com.mysql.jdbc.Driver
hibernate.connection.username=...
hibernate.connection.password=...
hibernate.connection.url=jdbc:mysql://localhost/hj3
hibernate.hbm2ddl.auto=create-drop
hibernate.cache.provider_class=org.hibernate.cache.HashtableCacheProvider
hibernate.jdbc.batch_size=0

jaxb to nosql
http://www.infoq.com/articles/MarkLogic-NoSQL-with-Transactions

http://xmlpipedb.cs.lmu.edu
http://sourceforge.net/projects/xmlpipedb/
http://xmlpipedb.cs.lmu.edu/download.shtml
http://xmlpipedb.cs.lmu.edu/docs/xmlpipedb-manual-20060731.pdf
http://xml2sql.sourceforge.net/
http://xmlpipedb.sourceforge.net/wiki/index.php/Using_XSD-to-DB

excel http://www.excel-easy.com/examples/xml.html
http://xmltodb.sourceforge.net/
http://sourceforge.net/projects/xmltodb/
http://xml2db.sourceforge.net
http://sourceforge.net/projects/xml2db/
http://xsd2db.sourceforge.net
http://sourceforge.net/projects/xsd2db/
https://code.google.com/p/xml2csv-conv/
https://github.com/knadh/xmlutils.py
http://sourceforge.net/projects/convertxmltocsv/
http://www.xsd2xml.com/

Advanced XML Converter 3.0 keygen

http://www.xml-converter.com/
http://www.imsoftly.com/index.php/products/easy-xml-converter
http://www.coolutils.com/XML-to-SQL-In-Batch
http://www.altova.com/xmlspy/database-xml.html
http://www.altova.com/mapforce.html
http://www.altova.com/xmlspy/database-xml.html
http://manual.altova.com/XMLSpy/spyenterprise/index.html?createdbstructurebasedonschema.htm
http://www.altova.com/download-convert-xml.html
http://www.stylusstudio.com/xsd-mapping.html

http://www.convertcsv.com/csv-to-xml.htm
http://www.luxonsoftware.com/converter/xmltocsv
http://xmlgrid.net/xml2text.html

https://github.com/philipmat/discogs-xml2db


SAP, Pentaho
https://www.youtube.com/watch?v=T0L_antzD3c


http://cdn.ttgtmedia.com/searchDataManagement/downloads/DB2pureXML_ch11.pdf 
http://stackoverflow.com/questions/7941353/xml-dtd-sql-schema
http://search.cpan.org/dist/SGML-DTDParse/bin/dtdparse
http://search.cpan.org/~metzzo/XML-RDB/RDB.pm


DATABASE XML
https://dev.mysql.com/doc/refman/5.5/en/load-xml.html

http://www.oracle.com/us/products/database/berkeley-db/xml/overview/index.html
http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_xmlgen.htm#i1012053
http://exist-db.org/exist/apps/doc/
http://www.oracle.com/technetwork/database/database-technologies/berkeleydb/downloads/index.html?ssSourceSiteId=ocomen
http://www.di.unipi.it/~ghelli/didattica/bdldoc/B19306_01/appdev.102/b14259/xdb03usg.htm#CEGDFBAJ

XMLTYPE
XMLTABLE

## DB

###EXIBIR TODAS AS LOCATIONS DE CURSO

  SELECT 
    locations.city, 
    locations.uf, 
    locations.uf_abbr, 
    locations.country, 
    locations.country_abbr, 
    courses.name, 
    universities.name, 
    universities.abbr
  FROM 
    public.universities, 
    public.courses, 
    public.locations
  WHERE 
    universities.location_id = locations.id AND
    courses.university_id = universities.id
  ORDER BY
    universities.name ASC;

###TAMANHO
  
  select pg_size_pretty(pg_database_size('lattesdata'));
  select pg_size_pretty(pg_table_size('curriculums'));

###ANÁLISE DE UNIVERSITY
universities.name NOT SIMILAR TO '%(\-|\,|\/|\(|\))%' AND
 universities.name NOT ILIKE '%universi%'  
 universities.name NOT ILIKE '%estadu%' 
 universities.name NOT ILIKE '%federal%' 
 universities.name NOT ILIKE '%univ%'

###PESSOAS QUE POSSUEM ORIENTAÇÃO
SELECT 
  people.name
FROM 
  public.orientations, 
  public.people
WHERE 
  orientations.person_id = people.id
ORDER BY
  people.name ASC;

#degrees

SELECT 
  people.name,
  locations.city, 
  locations.uf, 
  locations.country, 
  locations.latitude, 
  locations.longitude
FROM 
  public.locations,
  public.degrees, 
  public.universities, 
  public.people, 
  public.courses
WHERE 
  people.id = degrees.person_id AND
  courses.id = degrees.course_id AND
  courses.university_id = universities.id AND
  universities.location_id = locations.id AND
  people.id IN (SELECT DISTINCT orientations.person_id FROM public.orientations)

UNION ALL
#works

SELECT 
  people.name,
  locations.city, 
  locations.uf, 
  locations.country, 
  locations.latitude, 
  locations.longitude
FROM 
  public.locations, 
  public.universities, 
  public.people, 
  public.works
WHERE 
  universities.location_id = locations.id AND
  people.id = works.person_id AND
  works.university_id = universities.id AND
  people.id IN (SELECT DISTINCT orientations.person_id FROM public.orientations)

UNION ALL
#birth

SELECT 
  people.name,
  locations.city, 
  locations.uf, 
  locations.country, 
  locations.latitude, 
  locations.longitude
FROM 
  public.people, 
  public.locations
WHERE 
  people.location_id = locations.id AND
  people.id IN (SELECT DISTINCT orientations.person_id FROM public.orientations)

UNION ALL
#orientations 

SELECT 
  people.name,
  locations.city, 
  locations.uf, 
  locations.country, 
  locations.latitude, 
  locations.longitude
FROM 
  public.people, 
  public.orientations, 
  public.courses, 
  public.universities, 
  public.locations
WHERE
  courses.id = orientations.course_id AND
  courses.university_id = universities.id AND
  universities.location_id = locations.id
;

