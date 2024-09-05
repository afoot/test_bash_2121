TOMURL="https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.93/bin/apache-tomcat-9.0.93.tar.gz"
sudo apt install default-jdk maven -y
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
cd /tmp
sudo mkdir /opt/tomcat

wget $TOMURL -O tomcatbin.tar.gz
sudo tar xzvf tomcatbin.tar.gz -C /opt/tomcat --strip-components=1

cd /opt/tomcat
sudo chown -RH tomcat: /opt/tomcat
sudo sh -c 'chmod +x /opt/tomcat/bin/*.sh'

sudo update-java-alternatives -l


cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo systemctl status tomcat

sudo ufw allow 8080/tcp

git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git
cd vprofile-project
mvn install -DskipTests

systemctl stop tomcat
sleep 60
rm -rf /opt/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /opt/tomcat/webapps/ROOT.war
systemctl start tomcat
sleep 120
cp /vagrant/application.properties /opt/tomcat/webapps/ROOT/WEB-INF/classes/application.properties
systemctl restart tomcat



