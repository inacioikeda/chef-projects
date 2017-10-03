# # encoding: utf-8

# Inspec test for recipe tomcat9::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

# yum -y install java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-devel.x86_64
  describe package('java-1.8.0-openjdk') do
    it { should be_installed }
  end

# yum -y install java-1.8.0-openjdk-devel.x86_64
  describe package('java-1.8.0-openjdk-devel') do
    it { should be_installed }
  end

# TODO: ??
# vi /etc/environment
# JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.111-1.b15.el7_2.x86_64/jre export PATH=$JAVA_HOME/bin:$PATH
describe os_env('JAVA_HOME') do
  its('content') { should eq '/usr/lib/jvm/java-1.8.0-openjdk/' }
end

# groupadd tomcat
describe group 'tomcat' do
  it { should exist }
end

# useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
describe user 'tomcat' do
  it { should exist }
  its ('group') { should eq 'tomcat' }
  its ('home') { should eq '/opt/tomcat' }
  its ('shell') { should eq '/bin/false' }
end

# cd /opt/
# yum install wget http://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.0.M15/bin/apache-tomcat-9.0.0.M15.tar.gz
# tar -xzvf apache-tomcat-9.0.0.M15.tar.gz
# mv apache-tomcat-9.0.0.M15/* tomcat/
describe file('/opt/tomcat') do
  it { should exist }
  it { should be_directory }
  its ('size') { should > 0 }
end

# chown -hR tomcat:tomcat tomcat

  # vi /etc/systemd/system/tomcat.service
  # [Unit]
  # Description=Apache Tomcat 8 Servlet Container
  # After=syslog.target network.target[Service]
  # User=tomcat
  # Group=tomcat
  # Type=forking
  # Environment=CATALINA_PID=/opt/tomcat/tomcat.pid
  # Environment=CATALINA_HOME=/opt/tomcat
  # Environment=CATALINA_BASE=/opt/tomcat
  # ExecStart=/opt/tomcat/bin/startup.sh
  # ExecStop=/opt/tomcat/bin/shutdown.sh
  # Restart=on-failure
  # [Install] WantedBy=multi-user.target

  # systemctl daemon-reload

  # systemctl start tomcat

  # systemctl enable tomcat

  # vi /opt/tomcat/conf/tomcat-users.xml
  # <role rolename="manager-gui"/>
  # <user username="admin" password="password" roles="manager-gui,admin-gui"/>

  # vi /opt/tomcat/webapps/manager/META-INF/context.xml
  # <Context antiResourceLocking="false" privileged="true" >
  #  <!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
  #  allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
  # </Context>

  # systemctl restart tomcat

  # firewall-cmd --permanent --add-port=8080/tcp

  # firewall-cmd --reload
