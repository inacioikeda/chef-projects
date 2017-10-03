#
# Cookbook:: httpd
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

package 'httpd'

service 'httpd' do
  supports status: true
  action [:enable, :start]
end

file '/var/www/html/index.html' do
  content '<h1>OBA!!!</h1>'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

service 'httpd' do
  action [:restart]
end
