require 'thread/pool'
require 'date'
require 'debugger'

module ApplicationHelper

	class CaptchaError < StandardError  
	end 
	
	class DownloadZipError < StandardError  
	end

	class DownloadHtmlError < StandardError  
	end 

	class ScrapyError < StandardError  
	end 

	class Crawler
		# include Singleton
		
		def initialize
			@agent = Mechanize.new
			@retry_attempts = 5
		end

		def get(url)
			flag = 0
			begin
				page = @agent.get url
			rescue SocketError => error
				@logger ||= Logger.new("log/app-dump.log")
				@logger.warn "SocketError: #{url}"
			  if flag < @retry_attempts
			    flag += 1
			    sleep flag*2 
			    retry
			  end
			  puts $!, $@
			  raise
			end
			page
		end
	end

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
	end

	def extract_xml_data(record)
		if record['xml'].include? "<ERRO><MENSAGEM>Erro ao recuperar o XML</MENSAGEM></ERRO>"
			@logger ||= Logger.new("log/app-dump.log")
			@logger.info "XML #{record['id10']} com <ERRO>"
			return nil 
		end

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
		p.save
	end

	def extract_location_data
		start_time = Time.now

		@mutex ||= Mutex.new
		index = 0
		total = Curriculum.count
		page_size = 10000
		records = []
		
		(0..(total/page_size)).each{|page|
			offset = page*page_size
			records += Curriculum.find_by_sql("SELECT curriculums.id16 FROM public.curriculums LIMIT 10000 OFFSET 0").map{|c| c['id16']}.select{|id| id != nil}
		}

		size = records.length
		lattesPool = Thread.pool(30)
		
		records.each{|id16|
			lattesPool.process do
				begin
					record = Curriculum.find_by_id16(id16)
					
					data = extract_xml_data record
					print " x "
					
					#TODO last degree
					record_research_data data if data != nil
					print " d "
					
					@mutex.synchronize do
						index += 1
					end
					
					percentege = ((index)/size.to_f*100).round 2
					print "\n#D #{(index)}/#{size}: #{percentege}% "
				rescue
					@logger ||= Logger.new("log/app-dump.log")
					logger.error "extract location data #{record['id16']}"
					
					puts $!, $@
				end
			end
		}
		lattesPool.shutdown

		time_diff = Time.now - start_time
		time_diff = Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
		
		@logger ||= Logger.new("log/app-dump.log")
		@logger.info "Runtime of scrapy #{time_diff} - total #{size}"
	end

	alias_method :extract, :extract_location_data

	def scrapy(load: false, sample: nil)
		@logger ||= Logger.new("log/app-dump.log")
		@logger.info "scrapy lattes dump"

		# UPDATE XMLs monthly
		start_time = Time.now
		# id16 or xml == nil
		if load
			load_lattes_dump
			print " d "
		end
		print " i "

		sample ||= Curriculum.count
		retry_attempts = 3
		flag = 0
		# TODO retry
		# begin
			puts "\n>>>>scrapy"

			total = Curriculum.count
			page_size = 10000
			ids = []
			(0..(total/page_size)).each{|page|
				print '>'
				offset = page*page_size
				ids += Curriculum.find_by_sql("SELECT curriculums.id10, curriculums.id16 FROM public.curriculums LIMIT #{page_size} OFFSET #{offset}").select{|c| c['id16'] == nil}.map{|c| c['id10']}
			}
			lattes_infos = ids.uniq
			size = lattes_infos.length
			index = 0
			@mutex ||= Mutex.new

			puts "\n> size #{size}"
			
			lattesPool = Thread.pool(30)
			lattes_infos.each{|id10|	
				info = Curriculum.find_by_id10(id10)

				#TODO remove
				if info['xml'] != nil 
					index += 1
					next 
				end

				lattesPool.process do
					begin
						#TODO dump html
						data = get_html_data_lattes(info['id10'])
						print " h "
						
						raise ScrapyError if data == nil
						
						date = Date.strptime(data[:lattes_updated_at].to_s,"%d/%m/%Y")
						lattes_updated_at = date.strftime("%Y-%m-%d")

						xml = get_xml_lattes(data[:id16])
						print " x "

						curriculum = Curriculum.find_by(id10: info['id10'])
						curriculum.id16 = data[:id16]
						curriculum.scholarship = data[:scholarship]
						curriculum.lattes_updated_at = lattes_updated_at
						curriculum.xml = xml
						curriculum.updates << Update.find_or_create_by(lattes_updated_at: lattes_updated_at)
						curriculum.save
						print " . "

						@mutex.synchronize do
							index += 1
						end
						percentege = (index/size.to_f*100).round 2
						print "\n#X #{index}/#{size}: #{percentege}% "
					rescue ScrapyError => er
						@logger ||= Logger.new("log/app-dump.log")
						@logger.error "Scrapy id10 #{info['id10']} with HTML old"
						puts $!, $@
					rescue
						@logger ||= Logger.new("log/app-dump.log")
						@logger.error "Scrapy id10 #{info['id10']} - #{$!}"
						puts $!, $@
					end
				end

			}
			lattesPool.shutdown

				# lattes_infos = Curriculum.limit(sample).offset(0)
		# 	raise ScrapyError if lattes_infos.select{|c| c.id16 == nil}.length > 0
		# rescue ScrapyError => er
		# 	if flag < retry_attempts
		#     flag += 1
		# 		# retry
		# 	end
		# 	print " ! "
		# 	# puts $!, $@
		# end

		time_diff = Time.now - start_time
		time_diff = Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
		@logger ||= Logger.new("log/app-dump.log")
		@logger.info "Runtime of scrapy #{time_diff} - total #{size}"

		""
	end

	def load_lattes_dump(page_size:nil, number_page:nil)
		# TODO Filtro ???
		@logger ||= Logger.new("log/app-dump.log")
		@logger.info "load lattes dump"
		
		start_time = Time.now

		# todos
		# url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=0;10&query=%28+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
		# doutores
		url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=10;10&query=%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
		page_size ||= 100

		crawler = Crawler.new
		page = crawler.get url

		total = page.at('div.tit_form b').text
		number_page ||= (total.to_i/page_size)
		pages = (0..number_page)
		ids = []
		index = 0
		@mutex ||= Mutex.new
		
		lattesPool = Thread.pool(30)
		pages.each{|page|
			lattesPool.process do
				# todos
				# url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=#{page*page_size};#{page_size+20}&query=%28+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
				#doutores
				url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=#{page*page_size};#{page_size+20}&query=%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
				begin
					page_content = Crawler.new.get url
					page_ids = page_content.body.scan(/\'[\dA-Z]{10}\'/)
					page_ids[0..(page_size-1)].each{|research|
						ids << research[1..-2]
					}

					@logger ||= Logger.new("log/app-dump.log")
					@logger.info "Load #{page_ids[0..(page_size-1)].length} ids from page #{page}"
					@mutex.synchronize do
						index += 1
					end
					percentege = ((index)/number_page.to_f*100).round 2
					print "\n#P #{(index)}/#{number_page}: #{percentege}% "
				rescue
					@logger ||= Logger.new("log/app-dump.log")
					@logger.error "Load id10 #{url}"
					puts $!, $@
				end
			end
		}
		lattesPool.shutdown
		
		index = 0
		size = ids.length
		lattesPool = Thread.pool(30)
		ids.each{|id10|
			lattesPool.process do
				begin
					Curriculum.find_or_create_by(id10: id10)
					@mutex.synchronize do
						index += 1
					end
					percentege = ((index)/size.to_f*100).round 2
					print "\n#D #{(index)}/#{size}: #{percentege}% "
				rescue
					@logger ||= Logger.new("log/app-dump.log")
					@logger.error "Record id10 #{id10} #{$!}"
					puts $!, $@
				end
			end
		}
		lattesPool.shutdown
		time_diff = Time.now - start_time
		time_diff = Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
		@logger ||= Logger.new("log/app-dump.log")
		@logger.info "Runtime of load #{time_diff} - total ids #{size} from total #{total} recordos"
	end

	alias_method :load, :load_lattes_dump
	
	def get_html_data_lattes(id)
		#TODO inmemorium
		# http://buscatextual.cnpq.br/buscatextual/visualizacv.do?metodo=apresentar&id=K4759331Y9
		retry_attempts = 10
		begin
			page = Crawler.new.get  "http://buscatextual.cnpq.br/buscatextual/visualizacv.do?id=#{id}"
			scholarship = page.at('div.main-content div.infpessoa h2 span')
			id16 = page.at('.infpessoa .informacoes-autor li').text.split('cnpq.br/').last
			return nil if id16[/\d{16}/] == nil
			info = {
		  	# id10: page.at('div.main-content img.foto')['src'].split('id=').last,
		  	id16: id16,
		  	lattes_updated_at: page.at('div.main-content div.infpessoa ul').text[/\d{2}\/\d{2}\/\d{4}/],
		  	scholarship: scholarship == nil ? "" : scholarship.text
			}
			raise DownloadHtmlError if info[:id16] == nil
			return info
		rescue DownloadHtmlError
			@logger ||= Logger.new("log/app-dump.log")
			@logger.error "Get HTML id10 #{id}"
			if flag < retry_attempts
		    flag += 1
		    sleep flag*2 
				retry
			end		
			# puts $!, $@
			print " ! "
		end
	end

	def get_xml_lattes(id)
		xml = ""
		result = ""

		begin
			tempfile = Tempfile.new("#{id}-img")
			crawler = Crawler.new
			page = crawler.get "http://buscatextual.cnpq.br/buscatextual/sevletcaptcha?idcnpq=#{id}"
	    File.open(tempfile.path, 'wb') do |f|
	      f.write page.body
	    end
	    image = RTesseract.new(tempfile)
			result = image.to_s.strip
			tempfile.unlink
	    tempfile.close

			raise CaptchaError unless result != "" && result =~ /^[A-Z0-9]*$/
			
			page = crawler.get "http://buscatextual.cnpq.br/buscatextual/download.do?metodo=enviar&idcnpq=#{id}&palavra=#{result}"
			tempfile = Tempfile.new("#{id}-zip")
	    File.open(tempfile.path, 'wb') do |f| f.write page.body end
			has_doctype = File.read(tempfile).include? "DOCTYPE"
			
			if has_doctype
				tempfile.unlink
				tempfile.close
				raise CaptchaError 
			end
			
			xml = unzip_file(tempfile, id)
			tempfile.unlink
			tempfile.close

		rescue CaptchaError => er
			@logger ||= Logger.new("log/app-dump.log")
			@logger.warn "CaptchaError"
			#TODO limit retry
			# puts $!, $@
			print " ! "
			retry
		end
		
		xml
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

	# TODO

	def process_xml_size
	end

	def process_last_degree
		ids = Curriculum.where("degree IS NULL").pluck(:id).sort
		puts '>>ids'
		lattesPool = Thread.pool(50)
		ids.each{|id|
			lattesPool.process do
				print " [#{id}-#{(id/ids.size.to_f*100).round 2}%] " if id%150 == 0
				c = Curriculum.find(id)
				if c.xml.nil?
					next
				else
					next if c.xml.include? "<ERRO><MENSAGEM>Erro ao recuperar o XML</MENSAGEM></ERRO>"
					xmldoc = Nokogiri::XML(c.xml)
					degrees = []
					xmldoc.xpath("//FORMACAO-ACADEMICA-TITULACAO").children.each{|d|
						degrees.append(d.name)
					}
					c.degree = degrees.join(', ')
				end
				c.save
				c = nil
				GC.start if id%10000 == 0
			end
		}
		lattesPool.shutdown
	end

	def process_count_xml
		ids = Curriculum.where("xml_size IS NULL").pluck(:id).sort
		puts '>>ids'
		lattesPool = Thread.pool(50)
		ids.each{|id|
			lattesPool.process do
				print " [#{id}-#{(id/ids.size.to_f*100).round 2}%] " if id%150 == 0
				c = Curriculum.find(id)
				if c.xml.nil?
					c.xml_size = 0
				else
					c.xml_size = c.xml.bytesize
				end
				c.save
				c = nil
				GC.start if id%10000 == 0
				# xml.include? "<ERRO><MENSAGEM>Erro ao recuperar o XML</MENSAGEM></ERRO>"
			end
		}
		lattesPool.shutdown
	end

	def process_location_degree
	end

	def normalize_brazilian_locations
	end

	def normalize_country
		# lattesPool ||= Thread.pool(40)
		# Location.all.each{|l|
		# 	lattesPool.process do
		# 		if(l.country != l.country.downcase)
		# 			l.country = l.country.downcase
		# 			l.save
		# 		end
		# 	end
		# }
		# lattesPool.shutdown

		country_empty = Location.all.order('country ASC').select{|l| l.country == "" || l.country.nil?}
		country_empty.each{|l|
			if !l.latitude.nil?
				r = Geocoder.search("#{l.latitude}, #{l.longitude}")
				l.country = r[0].country.downcase
				puts l.address+"?"
				answer = gets.chop
				# next if answer == ""
				l.save
			end
		}

		# countries = Location.all.order('country ASC').select{|l| l.country != "" && !l.country.nil?}.map{|l| l.country}.uniq
		# @session ||= FreebaseAPI::Session.new(key: 'AIzaSyA4_6cLNet248boQno8NUBAGES89iypXUc', env: :stable)
		# offset = 0
		# countries[offset..-1].each_with_index{|country, index|
		# 	puts "\n##{index+offset}"
		# 	search = @session.search(country, {scoring: 'entity', filter: '(all type:/location/country)'})
		# 	next if search != []
		# 	# next if search.first['name'].downcase == country
		# 	search = (search == [])? '' : search.first['name'].downcase
		# 	# puts "Country: "+country
		# 	# puts "Result: "+search
		# 	print "\nDo you want?(\\n,o,n) "
		# 	puts search.downcase+" <- "+country
		# 	answer = gets.chop
		# 	next if answer == ""
		# 	if answer == "n"
		# 		puts "Enter new name"
		# 		answer = gets.chop
		# 	end
		# 	country_name = (answer == "o")? search : answer
		# 	result = Location.where("lower(country) = ?", country.downcase)
		# 	result = Location.where("country = ?", country) if result == []
		# 	lattesPool ||= Thread.pool(40)
		# 	result.each{|r|
		# 		lattesPool.process do
		# 			puts r.country+"->"+country_name
		# 			r.country =  country_name
		# 			r.save
		# 			r = nil
		# 		end
		# 	}
		# 	lattesPool.shutdown
		# }

	end

	def process_location_university
		# locations = University.find_by_sql("SELECT universities.id FROM public.universities, public.locations WHERE universities.location_id = locations.id AND locations.latitude IS NULL AND locations.longitude IS NULL AND locations.country = ''")
		locations = University.find_by_sql("SELECT universities.id FROM public.universities, public.locations WHERE universities.location_id = locations.id AND locations.latitude IS NULL AND locations.longitude IS NULL AND locations.country = '' AND universities.name LIKE '%universi%'")
		# countFail = 0
		lattesPool = Thread.pool(30)
		# locations[-13000..-10000].each{|uni|
		locations.each{|uni|
			lattesPool.process do
				uni = University.find(uni['id'])
				next if uni.name == ""
				print "\n"+uni.name+" "
				# result = process_location_university_geolocation(uni.name)
				result = process_location_university_freebase(uni.name)
				if !result.nil?
					uni.location = Location.find_or_create_by city: result[:city],
						country: result[:country],
						latitude: result[:lat],
						longitude: result[:lon] 
					uni.save
					uni = nil		  
			   	print '.'
		    else
		    	print 'x'
		    	# countFail += 1
			  end
			end
		}
		lattesPool.shutdown
		''
		# countFail
	end

	def process_location_university_geolocation(name)
		# TODO search by unisity class or type
	  g = Geocoder.search(name)
	  return nil if g.first.nil?
  	{
    	city: g.first.data['address']['city'],
    	country: g.first.data['address']['country'],
    	lat: g.first.data['lat'],
    	lon: g.first.data['lon']
  	}
	end

	def process_location_university_freebase(name)
		mql = mql(name)
		@session ||= FreebaseAPI::Session.new(key: 'AIzaSyA4_6cLNet248boQno8NUBAGES89iypXUc', env: :stable)
		result = @session.mqlread(mql)
		# binding.pry  
		if result == []
			# https://www.googleapis.com/freebase/v1/search?query=Università di Pavia&indent=true&any=/common/topic&limit=1
			search = @session.search(name, filter: '(all type:/common/topic)')
			return nil if search == []
			name = search.first["name"]
			# binding.pry  
			result = @session.mqlread(mql(name))
			if result.nil?
				result = @session.mqlread(mql_city(name)) 
			end
			return nil if result == []
			# binding.pry 
		end
		# binding.pry 
		citytown = result.first["/organization/organization/headquarters"]["/location/mailing_address/citytown"]
		country = result.first["/organization/organization/headquarters"]["/location/mailing_address/country"]
		country = if country.nil?
			nil
		else
			country["name"]["value"]
		end
		{
			city: citytown["name"],
			country: country,
			lat: citytown["/location/location/geolocation"]["/location/geocode/latitude"],
			lon: citytown["/location/location/geolocation"]["/location/geocode/longitude"]
		}
	end

	def mql(name)
		[{
		  :mid => nil,
		  :name => nil,
		  :'name~=' => name,
		  :type => "/education/university",
		  :'/organization/organization/headquarters' =>{
		    :'/location/mailing_address/citytown' => {
		      # :name => {
		      # 	:value => nil,
		      # 	:lang => "/lang/pt"
		      # },
		      :name => nil,
		      :mid => nil,
		      :id => nil,
		      :'/location/location/geolocation' => {
		        :mid => nil,
		        :'/location/geocode/latitude' => nil,
		        :'/location/geocode/longitude' => nil
		      }
		    },
		    :'/location/mailing_address/country' => {
		      :name => {
		      	:value => nil,
		      	:lang => "/lang/pt"
		      },
		      :mid => nil
		    }
		  }
		}]
	end

	def mql_city(name)
		[{
		  :mid => nil,
		  :name => nil,
		  :'name~=' => name,
		  :type => "/education/university",
		  :'/organization/organization/headquarters' =>{
		    :'/location/mailing_address/citytown' => {
		      # :name => {
		      # 	:value => nil,
		      # 	:lang => "/lang/pt"
		      # },
		      :name => nil,
		      :mid => nil,
		      :id => nil,
		      :'/location/location/geolocation' => {
		        :mid => nil,
		        :'/location/geocode/latitude' => nil,
		        :'/location/geocode/longitude' => nil
		      }
		    }
		  }
		}]
	end

end