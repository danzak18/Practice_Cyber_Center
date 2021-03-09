sudo apt-get install wget curl git 



wget -O - https://debian.neo4j.org/neotechnology.gpg.key | sudo apt-key add - 



echo 'deb http://debian.neo4j.org/repo stable/' | sudo tee /etc/apt/sources.list.d/neo4j.list 



echo "deb http://httpredir.debian.org/debian jessie-backports main" | sudo tee -a /etc/apt/sources.list.d/jessie-backports.list 



 



sudo apt-get update 



sudo apt-get install openjdk-8-jdk openjdk-8-jre 



sudo apt-get install neo4j 



echo "dbms.active_database=graph.db" >> /etc/neo4j/neo4j.conf 



echo "dbms.connector.http.address=0.0.0.0:7474" >> /etc/neo4j/neo4j.conf 



echo "dbms.connector.bolt.address=0.0.0.0:7687" >> /etc/neo4j/neo4j.conf 



echo "dbms.allow_format_migration=true" >> /etc/neo4j/neo4j.conf 



rm /var/lib/neo4j/data/dbms/auth 



 



 



echo neo4j:SHA-256,D1AAAEE1176D24F76BC1BBA0E36AD60D3E696A73490540BC473C81B3CD17A097,5CFF7B8784859C57B64354D192A8FB28B6297B88716DD90C644343EA49608F2B: > /var/lib/neo4j/data/dbms/auth 



service neo4j stop

service neo4j start
