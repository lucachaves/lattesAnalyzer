require 'thread/pool'

module ApplicationHelper

	def extract_node_data(node, xpath, kind=1)
		value = node.at_xpath(xpath)
		if kind == 1
			if value != nil
				value.value
			else
				value
			end
		elsif kind == 2
			value
		elsif kind == 3
			value[0].value
		end
		# puts ">>>>#{value}"
		# value
	end

	def extract_xml_data(file)
		$xmldoc = Nokogiri::XML(file)
		research = {}

		# TODO Modalidade de bolsa (HTML)??

		#id
		id = $xmldoc.xpath("//CURRICULO-VITAE/@NUMERO-IDENTIFICADOR")[0]
		research[:id] = (id != nil)? id.value : "" 

		# Atualização
		date = $xmldoc.xpath("//CURRICULO-VITAE/@DATA-ATUALIZACAO")[0].value
		research[:lattes_updated_at] = Date.strptime(date, '%d%m%Y').strftime('%Y-%m-%d')

		# NOME
		research[:name] = $xmldoc.xpath("//DADOS-GERAIS/@NOME-COMPLETO")[0].value

		# Nascimento
		research[:birth] = {}	
		research[:birth][:location] = {}	
		research[:birth][:location][:city] = $xmldoc.xpath("//DADOS-GERAIS/@CIDADE-NASCIMENTO")[0].value
		research[:birth][:location][:uf] = $xmldoc.xpath("//DADOS-GERAIS/@UF-NASCIMENTO")[0].value
		research[:birth][:location][:country] = $xmldoc.xpath("//DADOS-GERAIS/@PAIS-DE-NASCIMENTO")[0].value

		# Área de atuação
		research[:knowledge] = []
		knowledges = $xmldoc.xpath("//AREA-DE-ATUACAO")
		knowledges.each{|f|
			knowledge = {}
			knowledge[:major_subject] = extract_node_data(f, "@NOME-GRANDE-AREA-DO-CONHECIMENTO")
			knowledge[:subject] = extract_node_data(f, "@NOME-DA-AREA-DO-CONHECIMENTO")
			knowledge[:subsection] = extract_node_data(f, "@NOME-DA-SUB-AREA-DO-CONHECIMENTO")
			knowledge[:specialty] = extract_node_data(f, "@NOME-DA-ESPECIALIDADE")
			research[:knowledge] << knowledge
		}

		# WORK
		# TODO course ??? orientação?
		city = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@CIDADE")[0].value
		uf = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@UF")[0].value
		country = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@PAIS")[0].value
		university = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@NOME-INSTITUICAO-EMPRESA")[0].value
		organ = $xmldoc.xpath("//ENDERECO-PROFISSIONAL/@NOME-ORGAO")[0].value
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
		degree = $xmldoc.xpath("//FORMACAO-ACADEMICA-TITULACAO").children
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
		orientation = $xmldoc.xpath("//ORIENTACOES-CONCLUIDAS").children
		orientation += $xmldoc.xpath("//DADOS-COMPLEMENTARES/ORIENTACOES-EM-ANDAMENTO").children

		orientation.each{|f|
			name = f.name.split("-").last
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

	def record_research research
		# Person
		p = Person.create id16: research[:id], name: research[:name], lattes_updated_at: research[:lattes_updated_at]

		# Birth
		l = Location.find_or_create_by city: research[:birth][:location][:city], 
			uf: research[:birth][:location][:uf], 
			country: research[:birth][:location][:country]
		p.location = l

		# Degree
		research[:degree].each{|r|
			l = Location.find_or_create_by country: r[:location][:country], 
				country_abbr: r[:location][:country_abbr], 
				uf: r[:location][:uf_abbr]
			u = University.find_or_create_by name: r[:university], abbr: r[:university_abbr], location: l
			c = Course.find_or_create_by name: r[:course], university: u
			d = Degree.create name: r[:formation], year: r[:year], title: r[:title]
			d.course = c
			d.save
			p.degrees << d
		}

		# Knowledge
		research[:knowledge].each{|k|	
			p.knowledges << Knowledge.find_or_create_by(
					major_subject: k[:major_subject],
					major_subject: k[:major_subject],
					subject: k[:subject],
					subsection: k[:subsection],
					specialty: k[:specialty]
				)
		}

		# Work
		l = Location.find_or_create_by city: research[:work][:location][:city], 
				uf: research[:work][:location][:uf], 
				country: research[:work][:location][:country]
		u = University.find_or_create_by name: research[:work][:university], location: l
		p.work = Work.create organ: research[:work][:organ], university: u

		# Orientation
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
			
			orientation = Orientation.create document: o[:document],
				kind: o[:kind],
				title: o[:title],
				year: o[:year],
				language: o[:language],
				orientation: o[:orientation],
				student: o[:student],
				formation: o[:formation]
			orientation.course = c
			orientation.knowledge = k
			orientation.save

			p.orientations << orientation
		}
		p.save
	end

	def import_lattes_db
		lattes = []
		conn = PG.connect(host: '192.168.56.101', dbname: 'curriculos', user: 'postgres', password: 'postgres')
		res = conn.exec('select * from lattes')
		res.map{|row|
			row['xml']
		}
	end

	def process
		files = import_lattes_db
		# lattesPool = Thread.pool(1)
		# files[0..100].each{|f|
		files.each{|f|
			# lattesPool.process do
				begin
					r = extract_xml_data f
					record_research r
				rescue
					puts $!, $@
				end
			# end
		}
		# lattesPool.shutdown
	end

	# def create_lattes_db

	# end

	def scrapy
		#TODO encode, insert DB, source ids(id16, id10, bolsa)
		# f = File.read(data)
		# lattes_ids = f.split "\n"

		lattes_ids = [
			'3762670242328435',
			'1982919735990024'
		]
		lattesPool = Thread.pool(10)
		lattes_ids.each{|id|
			# next if File.exist?("lattes/#{id}.zip") || File.exist?("lattes/#{id}.xml")
			lattesPool.process do
				puts get_xml_lattes(id)
				# puts " [#{id}] "
			end
		}
		lattesPool.shutdown
	end

	def get_xml_lattes(id)
		# TODO try reopen url
		
		xml = ""
		(0..10).to_a.each{
			agent = Mechanize.new
			
			url = "http://buscatextual.cnpq.br/buscatextual/sevletcaptcha?idcnpq=#{id}"
			page  = agent.get url
			# page.save "temp/#{id}.png"
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
			xml = unzip_file(tempfile)
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

	def unzip_file(file)
	  Zip::ZipFile.open(file) { |zip_file|
	   zip_file.each { |f|
	     return f.get_input_stream.read
	   }
	  }
	end

end
