require 'thread/pool'
require 'nokogiri'
require 'open-uri'
require 'json'

module ApplicationHelper

	def extract(xpath)
		value = $xmldoc.xpath(xpath)
		if value.length < 1
			""
		else
			value[0].value
		end
	end

	def extractInfo(file)
		xmlfile = File.new("app/helpers/lattes/#{file}")
		$xmldoc = Nokogiri::XML(xmlfile)

		research = {}
		#id
		id = $xmldoc.xpath("//CURRICULO-VITAE/@NUMERO-IDENTIFICADOR")[0]
		if id != nil
			research[:id] = id.value
		else
			research[:id] = ""
		end	

		# Atualização
		research[:updated] = $xmldoc.xpath("//CURRICULO-VITAE/@DATA-ATUALIZACAO")[0].value

		# NOME
		research[:name] = $xmldoc.xpath("//DADOS-GERAIS/@NOME-COMPLETO")[0].value
		Person.create :name => research[:name]
		person = Person.last

		# Nascimento
		research[:birth] = {}	
		research[:birth][:location] = {}	
		research[:birth][:location][:city] = $xmldoc.xpath("//DADOS-GERAIS/@CIDADE-NASCIMENTO")[0].value
		research[:birth][:location][:uf] = $xmldoc.xpath("//DADOS-GERAIS/@UF-NASCIMENTO")[0].value
		research[:birth][:location][:country] = $xmldoc.xpath("//DADOS-GERAIS/@PAIS-DE-NASCIMENTO")[0].value

		# Modalidade de bolsa??

		# Área de atuação
		research[:knowledge] = []
		formation = $xmldoc.xpath("//AREA-DE-ATUACAO")
		formation.each{|f|
			knowledge = {}
			knowledge[:"NOME-GRANDE-AREA-DO-CONHECIMENTO"] = f.xpath("//@NOME-GRANDE-AREA-DO-CONHECIMENTO")[0].value
			knowledge[:"NOME-DA-AREA-DO-CONHECIMENTO"] = f.xpath("//@NOME-DA-AREA-DO-CONHECIMENTO")[0].value
			knowledge[:"NOME-DA-SUB-AREA-DO-CONHECIMENTO"] = f.xpath("//@NOME-DA-SUB-AREA-DO-CONHECIMENTO")[0].value
			knowledge[:"NOME-DA-ESPECIALIDADE"] = f.xpath("//@NOME-DA-ESPECIALIDADE")[0].value
			research[:knowledge] << knowledge
		}
		# PROFISSÃO
		# course ??? orientação?
		city = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@CIDADE")[0].value
		uf = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@UF")[0].value
		country = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@PAIS")[0].value
		university = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@NOME-INSTITUICAO-EMPRESA")[0].value
		orgao = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@NOME-ORGAO")[0].value
		research[:work] = {
			location: {
				city: city,
				uf: uf,
				country: country
			},
			university: university,
			orgao: orgao
		}

		# FORMAÇÃO
		# city, uf ???
		research[:formation] = []
		formation = $xmldoc.xpath("//FORMACAO-ACADEMICA-TITULACAO").children
		formation.each{|f|
			university = extract("//FORMACAO-ACADEMICA-TITULACAO/#{f.name}/@NOME-INSTITUICAO")
			universityCode = extract("//FORMACAO-ACADEMICA-TITULACAO/#{f.name}/@CODIGO-INSTITUICAO")
			country = extract("//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@NOME-PAIS-INSTITUICAO")
			university_abbr = extract("//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-INSTITUICAO")
			uf_abbr = extract("//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-UF-INSTITUICAO")
			country_abbr = extract("//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-PAIS-INSTITUICAO")
			course = extract("//FORMACAO-ACADEMICA-TITULACAO/#{f.name}/@NOME-CURSO")
			year = extract("//FORMACAO-ACADEMICA-TITULACAO/#{f.name}/@ANO-DE-CONCLUSAO")
			title = extract("//FORMACAO-ACADEMICA-TITULACAO/#{f.name}/@TITULO-DA-DISSERTACAO-TESE")
			
		# 	puts f.name
		# 	puts "#"
		# 	puts course
		# 	puts university
		# 	puts country
		# 	puts year
		# 	puts title
			research[:formation] << {
				formation: f.name.to_sym,
				location: {
					country: country,
					country_abbr: country_abbr,
					uf_abbr: uf_abbr
				},
				university: university,
				university_abbr: university_abbr,
				course: course,
				title: title,
				year: year
			}
		}
		puts JSON.pretty_generate(research)
		research
	end

	def recordResearch research
		# p = Person.create name: research[:name], id16: research[:id], updated: research[:updated]
		p = Person.create name: research[:name], updated: research[:updated]

		l = Location.create city: research[:birth][:location][:city], 
			uf: research[:birth][:location][:uf], 
			country: research[:birth][:location][:country]
		p.location = l

		research[:formation].each{|r|
			l = Location.create country: r[:location][:country]

			u = University.create name: r[:university]
			u.location = l
			u.save

			c = Course.create name: r[:course]
			c.university = u
			c.save

			d = Degree.create name: r[:formation], year: r[:year], title: r[:title]
			d.course = c
			d.save

			p.degrees << d
		}

		p.save
	end

	def process
		files = `ls app/helpers/lattes`.split "\n"
		# lattesPool = Thread.pool(1)
		# files[0..900].each{|f|
		files.each{|f|
			# lattesPool.process do
				next unless f.include? ".xml"
				begin
					r = extractInfo f
					recordResearch r
				rescue
					puts $!, $@
				end
			# end
		}
		# lattesPool.shutdown

	end
end
