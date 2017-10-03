#
# Cookbook:: Instalando e Configurando Tomcat 9
# Recipe:: default
# Maintainer:: Inacio Ikeda - Fabricads Soluções em TI - inacio.ikeda@fabricads.com.br
# Copyright:: 2017, The Authors, All Rights Reserved.

# yum -y install java-1.8.0-openjdk.x86_64
package 'java-1.8.0-openjdk.x86_64' do
  action :install
end

# yum -y install java-1.8.0-openjdk-devel.x86_64
package 'java-1.8.0-openjdk-devel.x86_64' do
  action :install
end

# TODO: Resolver export de variavél para Linux
#export JAVA_HOME='/usr/lib/jvm/java-1.8.0-openjdk/'
Environment="JAVA_HOME='/usr/lib/jvm/java-1.8.0-openjdk/'"

# groupadd tomcat useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
group 'tomcat' do
  action :create
end

# useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
user 'tomcat' do
  comment 'Tomcat User'
  manage_home false
  shell '/bin/false'
  group 'tomcat'
  home '/opt/tomcat'
  action :create
end

# yum install wget http://mirror.nbtelecom.com.br/apache/tomcat/tomcat-9/v9.0.1/bin/apache-tomcat-9.0.1.tar.gz
remote_file '/opt/apache-tomcat-9.0.1.tar.gz' do
  source 'http://mirror.nbtelecom.com.br/apache/tomcat/tomcat-9/v9.0.1/bin/apache-tomcat-9.0.1.tar.gz'
end

# Deletar antigos diretorios Tomcat
directory '/opt/tomcat' do
  recursive true
  action :delete
end

# Criar Diretorio Tomcat
directory '/opt/tomcat' do
  group 'tomcat'
  mode 0775
  recursive true
  action :create
end

# tar -xzvf apache-tomcat-9.0.1.tar.gz /
execute 'Untar' do
  command 'tar xvf /opt/apache-tomcat-9.0.1.tar.gz -C /opt/tomcat --strip-components=1'
  action :run
end

# apagar arquivos após término
file '/opt/apache-tomcat-9.0.1.tar.gz' do
  action :delete
end

# apagar pasta vazia
directory '/opt/apache-tomcat-9.0.1/' do
  recursive true
  action :delete
end

# sudo chgrp -R tomcat /opt/tomcat
execute 'chgrp' do
  command 'chgrp -R tomcat /opt/tomcat'
  action :run
end

# sudo chmod -R g+r conf
directory '/opt/tomcat/conf' do
  mode 70
end

# chmod -R g+r conf
execute 'chmod' do
  command 'chmod -R g+r /opt/tomcat/conf'
  action :run
end

# chmod -R g+x conf
execute 'chmod' do
  command 'chmod g+x /opt/tomcat/conf'
  action :run
end

# chown -hR tomcat:tomcat tomcat
%w[ logs temp webapps work ].each do |path|
  directory("/opt/tomcat/#{path}")  do
    owner 'tomcat'
    recursive true
  end
end

# vi /etc/systemd/system/tomcat.service
template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
end

# systemctl daemon-reload
execute 'Daemon' do
  command 'systemctl daemon-reload'
  action :run
end

# systemctl start tomcat e systemctl enable tomcat
service 'tomcat' do
  action [:enable, :start]
end

# vi /opt/tomcat/conf/tomcat-users.xml
template '/opt/tomcat/conf/tomcat-users.xml' do
  source 'tomcat-users.xml.erb'
  mode '0775'
end

# vi /opt/tomcat/webapps/manager/META-INF/context.xml
template '/opt/tomcat/webapps/manager/META-INF/context.xml' do
  source 'context.xml.erb'
  mode '0775'
end

# systemctl restart tomcat
service 'tomcat' do
  action :restart
end

# systemctl enable firewalld
execute 'enable-fw' do
  command 'systemctl enable firewalld && systemctl start firewalld'
  action :run
end

# firewall-cmd --permanent --add-port=8080/tcp
execute 'fw-allow' do
  command 'firewall-cmd --permanent --add-port=8080/tcp'
  action :run
end

# firewall-cmd --reload
execute 'fw-reload' do
  command 'firewall-cmd --reload'
  action :run
end
