#
# Cookbook Name:: sphinx
# Recipe:: default
#
# Copyright 2010, Alex Soto <apsoto@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "mysql::client" if node[:sphinx][:use_mysql]
include_recipe "postgresql::client" if node[:sphinx][:use_postgres]

if node[:sphinx][:use_package]
  include_recipe "sphinx::package"
else
  include_recipe "sphinx::source"
end

directory node['sphinx']['install_path'] do
  recursive true
end

template "#{node['sphinx']['install_path']}/etc/sphinx.conf" do
  source "sphinx.conf.erb"
  owner node[:sphinx][:user]
  group node[:sphinx][:group]
  mode '0644'
  variables :install_path => node['sphinx']['install_path']
end

directory "#{node['sphinx']['install_path']}/conf.d" do
  owner node[:sphinx][:user]
  group node[:sphinx][:group]
  mode '0755'
end

template "/etc/init.d/searchd" do
  source "searchd.erb"
  mode '0775'
  owner 'root'
  group 'root'
  variables :install_path => node['sphinx']['install_path']
end


service "searchd" do
  case node['platform']
  when "debian","ubuntu"
    service_name "searchd"
    restart_command "/usr/sbin/invoke-rc.d searchd restart && sleep 1"
    reload_command "/usr/sbin/invoke-rc.d searchd reload && sleep 1"
  end
  supports value_for_platform(
    "debian" => { "4.0" => [ :restart, :reload ], "default" => [ :restart, :reload, :status ] },
    "ubuntu" => { "default" => [ :restart, :reload, :status ] },
    "default" => { "default" => [:restart, :reload ] }
  )
  action :enable
end

#service "searchd" do
#  action :start
#end
