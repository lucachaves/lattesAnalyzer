require 'pg'

conn = PG.connect(host: '192.168.0.107', dbname: 'lattes', user: 'postgres', password: 'xmllattes')
res = conn.exec('select * from lattes')
res.each{|row|
	puts
	row.each{|col|
		print " #{col} "
	}
}