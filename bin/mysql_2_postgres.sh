file=$1
schema=`echo ${file} | sed s/_.*//`
echo ${schema}

cat ${file} | sed -e 's/NOT NULL DEFAULT CURRENT_TIMESTAMP/NOT NULL/' -e 's/NULL DEFAULT CURRENT_TIMESTAMP/NULL/' -e 's/`datum` timestamp/`datum` varchar(32)/' -e 's/NULL ON UPDATE CURRENT_TIMESTAMP/NULL/' -e 's/`timestamp` timestamp/`timestamp` varchar(32)/' -e "s/DEFAULT 'SLP'//" -e 's/`vertragsdatum` date/`vertragsdatum` varchar(16)/' -e 's/`datum` date /`datum` varchar(16) /' -e "s/NOT NULL DEFAULT '0'/NULL/" -e 's/date NOT NULL/varchar(16) NULL/' > ${file}.sql

echo "mysql drop old ${schema}"
echo "drop database ${schema};" | mysql -u root -p

echo "mysqlcreate ${schema}"
echo "create database ${schema};" | mysql -u root -p

echo "mysqlimport ${schema}"
mysql -u root -p < ${file}.sql

echo "pg drop create ${schema}"
dropdb ${schema}
createdb ${schema}

echo "convert mysql to pg"
pgloader -v mysql://root@localhost/${schema} postgresql:///${schema}

psql -d ${schema} -c "ALTER DATABASE ${schema} SET search_path TO ${schema}, public;"

echo "pg dump ${schema}"
pg_dump ${schema} > ${file/.sql/.postgres.sql}

echo 'zip pg dump'
zip ${file/.sql/.postgres.zip} ${file/.sql/.postgres.sql}
#rm ${file}.*sql