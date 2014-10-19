
module ApplicationHelper

	def extract(node, xpath, kind=1)
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

	def extractInfo(file)
		$xmldoc = Nokogiri::XML(file)

		research = {}
		#id
		id = $xmldoc.xpath("//CURRICULO-VITAE/@NUMERO-IDENTIFICADOR")[0]
		if id != nil
			research[:id] = id.value
		else
			research[:id] = ""
		end	

		# Atualização
		research[:lattes_updated_at] = $xmldoc.xpath("//CURRICULO-VITAE/@DATA-ATUALIZACAO")[0].value

		# NOME
		research[:name] = $xmldoc.xpath("//DADOS-GERAIS/@NOME-COMPLETO")[0].value

		# Nascimento
		research[:birth] = {}	
		research[:birth][:location] = {}	
		research[:birth][:location][:city] = $xmldoc.xpath("//DADOS-GERAIS/@CIDADE-NASCIMENTO")[0].value
		research[:birth][:location][:uf] = $xmldoc.xpath("//DADOS-GERAIS/@UF-NASCIMENTO")[0].value
		research[:birth][:location][:country] = $xmldoc.xpath("//DADOS-GERAIS/@PAIS-DE-NASCIMENTO")[0].value

		# Modalidade de bolsa??

		# Área de atuação
		research[:knowledge] = []
		knowledges = $xmldoc.xpath("//AREA-DE-ATUACAO")
		knowledges.each{|f|
			knowledge = {}
			knowledge[:major_subject] = extract(f, "@NOME-GRANDE-AREA-DO-CONHECIMENTO")
			knowledge[:subject] = extract(f, "@NOME-DA-AREA-DO-CONHECIMENTO")
			knowledge[:subsection] = extract(f, "@NOME-DA-SUB-AREA-DO-CONHECIMENTO")
			knowledge[:specialty] = extract(f, "@NOME-DA-ESPECIALIDADE")
			research[:knowledge] << knowledge
		}

		# WORK
		# course ??? orientação?
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
		# city, uf ???
		research[:degree] = []
		degree = $xmldoc.xpath("//FORMACAO-ACADEMICA-TITULACAO").children
		degree.each{|d|
			universityCode = extract(d, "@CODIGO-INSTITUICAO", 2)
			research[:degree] << {
				formation: d.name,
				location: {
					uf_abbr: extract(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-UF-INSTITUICAO"),
					country: extract(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@NOME-PAIS-INSTITUICAO"),
					country_abbr: extract(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-PAIS-INSTITUICAO")
				},
				university: extract(d, "@NOME-INSTITUICAO"),
				university_abbr: extract(d, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{universityCode}']/@SIGLA-INSTITUICAO"),
				course: extract(d, "@NOME-CURSO"),
				title: extract(d, "@TITULO-DA-DISSERTACAO-TESE"),
				year: extract(d, "@ANO-DE-CONCLUSAO", 2)
			}
		}

		#ORIENTAÇÕES
		research[:orientation] = []
		orientation = $xmldoc.xpath("//ORIENTACOES-CONCLUIDAS").children
		# # orientation << $xmldoc.xpath("//DADOS-COMPLEMENTARES/ORIENTACOES-EM-ANDAMENTO").children
		orientation.each{|f|
			name = f.name.split("-").last
			university_code = extract(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@CODIGO-INSTITUICAO", 2)
			university = {
				name: extract(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NOME-DA-INSTITUICAO"),
				abbr: extract(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@SIGLA-INSTITUICAO"),
				location: {
					country: extract(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@NOME-PAIS-INSTITUICAO"),
					uf_country: extract(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@SIGLA-PAIS-INSTITUICAO"),
					uf_abbr: extract(f, "//INFORMACAO-ADICIONAL-INSTITUICAO[@CODIGO-INSTITUICAO='#{university_code}']/@SIGLA-UF-INSTITUICAO")
				}
			}
			course_code = extract(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@CODIGO-CURSO", 2)
			knowledge = {
				major_subject: extract(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-GRANDE-AREA-DO-CONHECIMENTO"),
				subject: extract(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-DA-AREA-DO-CONHECIMENTO"),
				subsection: extract(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-DA-SUB-AREA-DO-CONHECIMENTO"),
				specialty: extract(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NOME-DA-ESPECIALIDADE")
			}
			course = {
				name: extract(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NOME-DO-CURSO"),
				knowledge: knowledge
			}
			research[:orientation] << {
				student: extract(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NOME-DO-ORIENTADO"),
				document: extract(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@NATUREZA"),
				# phd, master
				kind: extract(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@TIPO"),
				#degree
				formation: extract(f, "//INFORMACAO-ADICIONAL-CURSO[@CODIGO-CURSO='#{course_code}']/@NIVEL-CURSO"),
				title: extract(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@TITULO"),
				year: extract(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@ANO"),
				language: extract(f, "DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@IDIOMA"),
				orientation: extract(f, "DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-#{name}/@TIPO-DE-ORIENTACAO"),
				university: university,
				course: course
			}
		}
		puts JSON.pretty_generate(research)
		research
	end

	def recordResearch research
		# TODO if exist (CHECK)

		# Person
		p = Person.create id16: research[:id], name: research[:name], lattes_updated_at: research[:lattes_updated_at]
		# p = Person.create name: research[:name], lattes_updated_at: research[:lattes_updated_at]

		# Birth CHECK
		l = Location.create city: research[:birth][:location][:city], 
			uf: research[:birth][:location][:uf], 
			country: research[:birth][:location][:country]
		p.location = l

		# Degree
		research[:degree].each{|r|
			# location CHECK
			l = Location.create country: r[:location][:country], 
				country_abbr: r[:location][:country_abbr], 
				uf_abbr: r[:location][:uf_abbr]

			# University CHECK
			u = University.create name: r[:university], abbr: r[:university_abbr]
			u.location = l
			u.save

			# Course CHECK
			c = Course.create name: r[:course]
			c.university = u
			c.save

			# Degree
			d = Degree.create name: r[:formation], year: r[:year], title: r[:title]
			d.course = c
			d.save

			p.degrees << d
		}

		# Knowledge CHECK
		research[:knowledge].each{|r|	
			k = Knowledge.create major_subject: r[:major_subject],
					major_subject: r[:major_subject],
					subject: r[:subject],
					subsection: r[:subsection],
					specialty: r[:specialty]
			p.knowledges << k
		}

		# Work
		w = Work.create organ: research[:work][:organ]
		# CHECK
		l = Location.create city: research[:work][:location][:city], 
				uf: research[:work][:location][:uf], 
				country: research[:work][:location][:country]
		# CHECK
		u = University.create name: research[:work][:university]
		u.location = l
		u.save
		w.university = u
		w.save
		p.work = w

		# Orientation
		research[:orientation].each{|o|
			orientation = Orientation.create document: o[:document],
				kind: o[:kind],
				title: o[:title],
				year: o[:year],
				language: o[:language],
				orientation: o[:orientation],
				student: o[:student],
				formation: o[:formation]
			# CHECK
			l = Location.create uf_abbr: o[:university][:location][:uf_abbr], 
				country_abbr: o[:university][:location][:uf_country], 
				country: o[:university][:location][:country]
			# CHECK
			u = University.create name: o[:university][:name]
				abbr: o[:university][:abbr]
			u.location = l
			u.save
		
			# CHECK
			c = Course.create name: o[:course][:name]
			c.university = u
			c.save
			orientation.course = c
			
			# CHECK
			k = Knowledge.create major_subject: o[:course][:knowledge][:major_subject],
					major_subject: o[:course][:knowledge][:major_subject],
					subject: o[:course][:knowledge][:subject],
					subsection: o[:course][:knowledge][:subsection],
					specialty: o[:course][:knowledge][:specialty]
			orientation.knowledge = k
			orientation.save

			p.orientations << orientation
		}
		p.save
	end

	def get_lattes
		lattes = []
		conn = PG.connect(host: '192.168.56.101', dbname: 'curriculos', user: 'postgres', password: 'postgres')
		res = conn.exec('select * from lattes')
		res.map{|row|
			row['xml']
		}
		# `ls app/helpers/lattes`.split "\n"
	end

	def process
		files = get_lattes
		# lattesPool = Thread.pool(1)
		# files[0..100].each{|f|
		files.each{|f|
			# lattesPool.process do
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
