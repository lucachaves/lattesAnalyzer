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
				Rails.logger = Logger.new("log/app-dump.log")
				Rails.logger.warn "SocketError: #{url}"
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
			Rails.logger = Logger.new("log/app-dump.log")
			Rails.logger.info "XML #{record['id10']} com <ERRO>"
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
		records = Curriculum.select{|c| c.id16 != nil}
		# records = Curriculum.all(:conditions => "id16 IS NOT NULL")
		size = records.length
		lattesPool = Thread.pool(30)
		index = 0
		@mutex = Mutex.new
		
		records.each{|record|
			next unless Person.find_by(id16: record['id16']) == nil
			lattesPool.process do
				begin
					data = extract_xml_data record
					print " x "
					record_research_data data if data != nil
					print " d "
					
					percentege = ((index)/size.to_f*100).round 2
					print "\n#D #{(index)}/#{size}: #{percentege}% "
				rescue
					Rails.logger = Logger.new("log/app-dump.log")
					logger.error "extract location data #{record['id16']}"
					puts $!, $@
				end
			end
			@mutex.synchronize do
				index += 1
			end
		}
		lattesPool.shutdown

		time_diff = Time.now - start_time
		time_diff = Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
		Rails.logger = Logger.new("log/app-dump.log")
		Rails.logger.info "Runtime of scrapy #{time_diff} - total #{size}"

		""
	end

	alias_method :extract, :extract_location_data

	def load_lattes_dump(page_size:nil, number_page:nil)
		Rails.logger = Logger.new("log/app-dump.log")
		Rails.logger.info "load lattes dump"
		start_time = Time.now
		# logger.info "load lattes dump"
		# TODO Filtro ???

		# todos
		url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=0;10&query=%28+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
		# doutores
		# url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=10;10&query=%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
		page_size ||= 100

		crawler = Crawler.new
		page = crawler.get url
		# debugger

		total = page.at('div.tit_form b').text
		number_page ||= (total.to_i/page_size)
		pages = (0..number_page)
		ids = []
		index = 0
		@mutex = Mutex.new
		
		# debugger
		lattesPool = Thread.pool(30)
		pages.each{|page|
			lattesPool.process do
				# todos
				url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=#{page*page_size};#{page_size+20}&query=%28+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
				#doutores
				# url = "http://buscatextual.cnpq.br/buscatextual/busca.do?metodo=forwardPaginaResultados&registros=#{page*page_size};#{page_size+20}&query=%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ae%29+or+%28+%2Bidx_particao%3A1+%2Bidx_nacionalidade%3Ab%29&analise=cv&tipoOrdenacao=null&paginaOrigem=index.do&mostrarScore=false&mostrarBandeira=false&modoIndAdhoc=null"
				begin
					page_content = Crawler.new.get url
					page_ids = page_content.body.scan(/\'[\dA-Z]{10}\'/)
					page_ids[0..(page_size-1)].each{|research|
						ids << research[1..-2]
					}

					Rails.logger = Logger.new("log/app-dump.log")
					Rails.logger.info "Load #{page_ids[0..(page_size-1)].length} ids from page #{page}"
					@mutex.synchronize do
						index += 1
					end
					percentege = ((index)/number_page.to_f*100).round 2
					print "\n#P #{(index)}/#{number_page}: #{percentege}% "
				rescue
					Rails.logger = Logger.new("log/app-dump.log")
					Rails.logger.error "Load id10 #{url}"
					puts $!, $@
				end
			end
		}
		lattesPool.shutdown
		
		index = 0
		size = ids.length
		debugger
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
					Rails.logger = Logger.new("log/app-dump.log")
					Rails.logger.error "Record id10 #{id10} #{$!}"
					puts $!, $@
				end
			end
		}
		lattesPool.shutdown
		time_diff = Time.now - start_time
		time_diff = Time.at(time_diff.to_i.abs).utc.strftime "%H:%M:%S"
		Rails.logger = Logger.new("log/app-dump.log")
		Rails.logger.info "Runtime of load #{time_diff} - total ids #{size} from total #{total} recordos"
	end

	alias_method :load, :load_lattes_dump

	def scrapy(load: false, sample: nil)
		Rails.logger = Logger.new("log/app-dump.log")
		Rails.logger.info "scrapy lattes dump"

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
		# begin
			puts "\n>>>>scrapy"

			lattes_infos = Curriculum.limit(sample).offset(0).where(id16:nil)
			# lattes_infos = lattes_infos.select{|c| c.id16 == nil}
			size = lattes_infos.length
			index = 0
			@mutex = Mutex.new

			puts "\n> size #{size}"

			lattesPool = Thread.pool(30)
			lattes_infos.each{|info|	

				#TODO remove
				unless info['xml'] == nil 
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
						# debugger
						curriculum.save
						print " . "

						@mutex.synchronize do
							index += 1
						end
						percentege = (index/(size+1).to_f*100).round 2
						print "\n#X #{index}/#{size+1}: #{percentege}% "
					rescue ScrapyError => er
						Rails.logger = Logger.new("log/app-dump.log")
						Rails.logger.error "Scrapy id10 #{info['id10']} with HTML old"
						puts $!, $@
					rescue
						Rails.logger = Logger.new("log/app-dump.log")
						Rails.logger.error "Scrapy id10 #{info['id10']} - #{$!}"
						puts $!, $@
					end
				end

			}
			lattesPool.shutdown

			# debugger
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
		Rails.logger = Logger.new("log/app-dump.log")
		Rails.logger.info "Runtime of scrapy #{time_diff} - total #{size}"

		""
	end
	
	def get_html_data_lattes(id)
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
			Rails.logger = Logger.new("log/app-dump.log")
			Rails.logger.error "Get HTML id10 #{id}"
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
			Rails.logger = Logger.new("log/app-dump.log")
			Rails.logger.warn "CaptchaError"
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

end
