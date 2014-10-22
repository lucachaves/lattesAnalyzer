require 'thread/pool'
require 'date'
require 'debugger'

module ApplicationHelper

	def extract_node_data(node, xpath, kind=1)
		value =	node.at_xpath(xpath)
		# puts ">>>>#{value}"

		return "" if value == nil
		
		if kind == 1
			value.value
		elsif kind == 2
			value
		elsif kind == 3
			value[0].value
		elsif kind == 4
			value[0]
		end
		# value
	end

	def extract_xml_data(record)
		return nil if record['xml'].include? "<ERRO><MENSAGEM>Erro ao recuperar o XML</MENSAGEM></ERRO>"
		xmldoc = Nokogiri::XML(record['xml'])
		research = {}

		#ids
		research[:id10] = record['id10']
		research[:id16] = record['id16']
		research[:scholarship] = record['scholarship']

		# Atualização
		date = extract_node_data(xmldoc, "//CURRICULO-VITAE/@DATA-ATUALIZACAO", 2)
		research[:lattes_updated_at] = Date.strptime(date, '%d%m%Y').strftime('%Y-%m-%d')

		# NOME
		research[:name] = extract_node_data(xmldoc, "//DADOS-GERAIS/@NOME-COMPLETO")

		# Nascimento
		research[:birth] = {}	
		research[:birth][:location] = {}	
		research[:birth][:location][:city] = extract_node_data(xmldoc, "//DADOS-GERAIS/@CIDADE-NASCIMENTO")
		research[:birth][:location][:uf] = extract_node_data(xmldoc, "//DADOS-GERAIS/@UF-NASCIMENTO")
		research[:birth][:location][:country] = extract_node_data(xmldoc, "//DADOS-GERAIS/@PAIS-DE-NASCIMENTO")

		# Área de atuação
		research[:knowledge] = []
		knowledges = xmldoc.xpath("//AREA-DE-ATUACAO")
		knowledges.each{|f|
			knowledge = {}
			knowledge[:major_subject] = extract_node_data(f, "@NOME-GRANDE-AREA-DO-CONHECIMENTO")
			knowledge[:subject] = extract_node_data(f, "@NOME-DA-AREA-DO-CONHECIMENTO")
			knowledge[:subsection] = extract_node_data(f, "@NOME-DA-SUB-AREA-DO-CONHECIMENTO")
			knowledge[:specialty] = extract_node_data(f, "@NOME-DA-ESPECIALIDADE")
			research[:knowledge] << knowledge
		}

		# WORK
		# TODO course ??? orientation??
		city = extract_node_data(xmldoc, "//ENDERECO-PROFISSIONAL/@CIDADE")
		uf = extract_node_data(xmldoc, "//ENDERECO-PROFISSIONAL/@UF")
		country = extract_node_data(xmldoc, "//ENDERECO-PROFISSIONAL/@PAIS")
		university = extract_node_data(xmldoc, "//ENDERECO-PROFISSIONAL/@NOME-INSTITUICAO-EMPRESA")
		organ = extract_node_data(xmldoc, "//ENDERECO-PROFISSIONAL/@NOME-ORGAO")
		research[:work] = {
			location: {
				city: city,
				uf: uf,
				country: country
			},
			university: university,
			organ: organ
		}

		# DEGREE
		# TODO city, uf ???
		research[:degree] = []
		degree = xmldoc.xpath("//FORMACAO-ACADEMICA-TITULACAO").children
		degree.each{|d|
			universityCode = extract_node_data(d, "@CODIGO-INSTITUICAO", 2)
			research[:degree] << {
				formation: d.name,
				location: {
					uf_abbr: extract_node_data(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-UF-INSTITUICAO"),
					country: extract_node_data(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@NOME-PAIS-INSTITUICAO"),
					country_abbr: extract_node_data(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-PAIS-INSTITUICAO")
				},
				university: extract_node_data(d, "@NOME-INSTITUICAO"),
				university_abbr: extract_node_data(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-INSTITUICAO"),
				course: extract_node_data(d, "@NOME-CURSO"),
				title: extract_node_data(d, "@TITULO-DA-DISSERTACAO-TESE"),
				year: extract_node_data(d, "@ANO-DE-CONCLUSAO")
			}
		}

		#ORIENTAÇÕES
		research[:orientation] = []
		orientation = xmldoc.xpath("//ORIENTACOES-CONCLUIDAS").children
		orientation += xmldoc.xpath("//DADOS-COMPLEMENTARES/ORIENTACOES-EM-ANDAMENTO").children

		orientation.each{|f|
			name = f.name.split("-").last
			next unless ['MESTRADO', 'DOUTORADO'].include? name
			university_code = extract_node_data(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@CODIGO-INSTITUICAO", 2)
			university = {
				name: extract_node_data(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NOME-DA-INSTITUICAO"),
				abbr: extract_node_data(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@SIGLA-INSTITUICAO"),
				location: {
					country: extract_node_data(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@NOME-PAIS-INSTITUICAO"),
					uf_country: extract_node_data(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@SIGLA-PAIS-INSTITUICAO"),
					uf_abbr: extract_node_data(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@SIGLA-UF-INSTITUICAO")
				}
			}
			course_code = extract_node_data(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@CODIGO-CURSO", 2)
			knowledge = {
				major_subject: extract_node_data(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-GRANDE-AREA-DO-CONHECIMENTO"),
				subject: extract_node_data(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-DA-AREA-DO-CONHECIMENTO"),
				subsection: extract_node_data(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-DA-SUB-AREA-DO-CONHECIMENTO"),
				specialty: extract_node_data(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-DA-ESPECIALIDADE")
			}
			course = {
				name: extract_node_data(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NOME-DO-CURSO"),
				knowledge: knowledge
			}
			research[:orientation] << {
				student: extract_node_data(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NOME-DO-ORIENTADO"),
				document: extract_node_data(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NATUREZA"),
				# phd, master
				kind: extract_node_data(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@TIPO"),
				#degree
				formation: extract_node_data(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NIVEL-CURSO"),
				title: extract_node_data(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@TITULO"),
				year: extract_node_data(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@ANO"),
				language: extract_node_data(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@IDIOMA"),
				orientation: extract_node_data(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@TIPO-DE-ORIENTACAO"),
				university: university,
				course: course
			}
		}
		# puts JSON.pretty_generate(research)
		research
	end

	def record_research_data research
		# Person
		# debugger
		p = Person.find_or_create_by id16: research[:id16], 
			id10: research[:id10], 
			name: research[:name], 
			scholarship: research[:scholarship], 
			lattes_updated_at: research[:lattes_updated_at]

		# Birth
		p.location = Location.find_or_create_by city: research[:birth][:location][:city], 
			uf: research[:birth][:location][:uf], 
			country: research[:birth][:location][:country]

		# Work
		l = Location.find_or_create_by city: research[:work][:location][:city], 
				uf: research[:work][:location][:uf], 
				country: research[:work][:location][:country]
		u = University.find_or_create_by name: research[:work][:university], location: l
		p.work = Work.find_or_create_by organ: research[:work][:organ], university: u

		# Degrees
		research[:degree].each{|degree|
			l = Location.find_or_create_by country: degree[:location][:country], 
				country_abbr: degree[:location][:country_abbr], 
				uf: degree[:location][:uf_abbr]
			u = University.find_or_create_by name: degree[:university], 
				abbr: degree[:university_abbr], 
				location: l
			c = Course.find_or_create_by name: degree[:course], 
				university: u
			# debugger
			p.degrees << Degree.find_or_create_by(
				name: degree[:formation], 
				year: degree[:year], 
				title: degree[:title], 
				course: c
			)
		}

		# Knowledges
		research[:knowledge].each{|knowledge|	
			p.knowledges << Knowledge.find_or_create_by(
					major_subject: knowledge[:major_subject],
					major_subject: knowledge[:major_subject],
					subject: knowledge[:subject],
					subsection: knowledge[:subsection],
					specialty: knowledge[:specialty]
				)
		}

		# Orientations
		research[:orientation].each{|o|
			l = Location.find_or_create_by uf: o[:university][:location][:uf_abbr], 
				country_abbr: o[:university][:location][:uf_country], 
				country: o[:university][:location][:country]

			u = University.find_or_create_by name: o[:university][:name],
				abbr: o[:university][:abbr],
				location: l
		
			c = Course.find_or_create_by name: o[:course][:name],
				university: u
			
			k = Knowledge.find_or_create_by major_subject: o[:course][:knowledge][:major_subject],
					major_subject: o[:course][:knowledge][:major_subject],
					subject: o[:course][:knowledge][:subject],
					subsection: o[:course][:knowledge][:subsection],
					specialty: o[:course][:knowledge][:specialty]
			
			p.orientations << Orientation.find_or_create_by(
				document: o[:document],
				kind: o[:kind],
				title: o[:title],
				year: o[:year],
				language: o[:language],
				orientation: o[:orientation],
				student: o[:student],
				formation: o[:formation],
				course: c,
				knowledge: k
			)
		}
		# debugger
		p.save
	end

	def extract_location_data
		records = import_lattes_db
		# lattesPool = Thread.pool(1)
		# records[0..0].each{|record|
		records.each{|record|
			# lattesPool.process do
				next unless Person.find_by(id16: record['id16']) == nil
				begin
					data = extract_xml_data record
					print " x "
					record_research_data data if data != nil
					print " d "
					# TODO % execution
				rescue
					puts $!, $@
				end
			# end
		}
		# lattesPool.shutdown
		">>> stop extract location"
	end

	alias_method :extract, :extract_location_data

	def import_lattes_db 
		lattes = []
		@conn = PG.connect(host: '192.168.56.101', dbname: 'curriculos', user: 'postgres', password: 'postgres')
		@conn.prepare('statement0', 'select * from curriculums')
		res = @conn.exec_prepared('statement0', [])
		res.map{|row|
			row
		}
	end

	def get_lattes_db id
		@conn = PG.connect(host: '192.168.56.101', dbname: 'curriculos', user: 'postgres', password: 'postgres')
		@conn.prepare('statement1', 'select * from curriculums where curriculums.id10 = $1')
		res = @conn.exec_prepared('statement1', [id])
		res.map{|row|
			row
		}
	end

	def create_lattes_db
		# Total 3900735 (10/2014)
		# PQ 14339 (1[ABCD], 2)
		# Outras Bolsas
		# D 201984
		# M 394958
		# E 733707
		# G 2005267
		# D+G+M+G 3335916 (Resta 564819 Técn, Granduando, EM)

		@conn = PG.connect(host: '192.168.56.101', dbname: 'curriculos', user: 'postgres', password: 'postgres')
		
		agent = Mechanize.new
		url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=0;100&query=( +idx_nacionalidade:e) or ( +idx_nacionalidade:b)&analise=cv"
		page  = agent.get url

		totol = page.at('div.tit_form b').text
		# TODO pagging & concurrent

		# TODO if not exist
		@conn.prepare('statement2', 'INSERT INTO curriculums (id10, degree) SELECT $1, $2 WHERE NOT EXISTS (SELECT id10 FROM curriculums WHERE id10 = $1)')

		page.search('.resultado b a').each{|research|
			id10 = research['href'].split("'")[1]
			@conn.exec_prepared('statement2', [id10, ''])
			# TODO % execution
		}

	end

	def scrapy
		@conn = PG.connect(host: '192.168.56.101', dbname: 'curriculos', user: 'postgres', password: 'postgres')
		
		create_lattes_db
		print " d "

		lattes_infos = import_lattes_db
		print " i "

		# lattesPool = Thread.pool(10)
		@conn.prepare('statement3', 'UPDATE curriculums SET id16=$1, lattes_updated_at=$3, scholarship=$4, xml=$5 WHERE id10 = $2')
		lattes_infos.each{|info|
			next unless info['xml'] == nil 
			# lattesPool.process do
				data = get_html_data_lattes(info['id10'])
				print " h "

				date = Date.strptime(data['lattes_updated_at'].to_s,"%d/%m/%Y")
				lattes_updated_at = date.strftime("%Y-%m-%d")

				xml = get_xml_lattes(data['id16'])
				print " x "
			# id16, id10, lattes_updated_at, scholarship, degree (G, E, M, D, P)
			# 1982919735990024,K4778631T5,2014-09-20,-,D 
				@conn.exec_prepared('statement3', [data['id16'], info['id10'], lattes_updated_at, data['scholarship'], xml])
				print " . "
				# TODO % execution
			# end
		}
		# lattesPool.shutdown
	end
	
	def get_html_data_lattes(id)
		agent = Mechanize.new
		# url = "http://lattes.cnpq.br/#{id}"
		url = "http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=#{id}"
		page  = agent.get url
		info = {}
  	# info['id10'] = page.at('div.main-content img.foto')['src'].split('id=').last
  	info['id16'] = page.at('.infpessoa .informacoes-autor li').text.split('cnpq.br/').last
  	info['lattes_updated_at'] = page.at('div.main-content div.infpessoa ul').text[/\d{2}\/\d{2}\/\d{4}/]
  	scholarship = page.at('div.main-content div.infpessoa h2 span')
  	info['scholarship'] = scholarship == nil ? "" : scholarship.text 
  	info
	end

	def get_xml_lattes(id)
		# TODO try reopen url		
		xml = ""
		(0..10).to_a.each{
			agent = Mechanize.new
			url = "http://buscatextual.cnpq.br/buscatextual/sevletcaptcha?idcnpq=#{id}"
			page  = agent.get url
			tempfile = Tempfile.new("#{id}-img")
	    File.open(tempfile.path, 'wb') do |f|
	      f.write page.body
	    end
			result = check_captcha tempfile
			tempfile.unlink
	    tempfile.close
			
			url = "http://buscatextual.cnpq.br/buscatextual/download.do?metodo=enviar&idcnpq=#{id}&palavra=#{result}"
			page = agent.get url
			tempfile = Tempfile.new("#{id}-zip")
	    File.open(tempfile.path, 'wb') do |f|
	      f.write page.body
	    end
			next if File.read(tempfile).include? "DOCTYPE"
			xml = unzip_file(tempfile, id)
			tempfile.unlink
			tempfile.close
			return xml
		}
	end

	def check_captcha(file)
		result = ''
		(0..10).to_a.each{
			image = RTesseract.new(file)
			result = image.to_s.strip
			break if result != "" && result =~ /^[A-Z0-9]*$/
		}
		result
	end

	def unzip_file(file, id)
	  Zip::ZipFile.open(file) { |zip_file|
	   zip_file.each { |f|
	    xml = f.get_input_stream.read
	    tempfile = Tempfile.new("#{id}-xml")
	    File.open(tempfile.path, 'wb') do |f|
	      f.write xml
	    end
	    File.open(tempfile, "r:iso-8859-1:utf-8") do |io|
			  xml = io.read
			end
	    tempfile.unlink
			tempfile.close
			return xml
	   }
	  }
	end

end
