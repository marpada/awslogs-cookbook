#
# Cookbook Name:: awslogs-agent
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{bin etc lib local state}.each do |f|
  directory "#{node['awslogs_agent']['path']}/#{f}" do
    owner node['awslogs_agent']['user']
    group node['awslogs_agent']['group']
    mode '0755'
    recursive true
  end
end

include_recipe 'poise-python'

python_virtualenv node['awslogs_agent']['path'] do
  action :create
  user node['awslogs_agent']['user']
  group node['awslogs_agent']['group']
end

python_package "awscli-cwlogs" do
  virtualenv node['awslogs_agent']['path']
  version node['awslogs_agent']['version']
  options "--extra-index-url=#{node['awslogs_agent']['plugin_url']}"
end

destination_folder = ''
source_file = ''
if  'ubuntu' == node['platform']
  if Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version'])
    destination_folder = "/lib/systemd/system/#{node['awslogs_agent']['service']}.service"
    source_file = "etc/systemd/awslogs_daemon.service.erb"
  elsif Chef::VersionConstraint.new('>= 12.04').include?(node['platform_version'])
    destination_folder = "/etc/init/#{node['awslogs_agent']['service']}.conf"
    source_file = "etc/init/awslogs.conf.erb"
  end
end

template destination_folder do
  owner 'root'
  group 'root'
  mode '0644'
  source source_file
  variables(
    :user => node['awslogs_agent']['user'],
    :path => node['awslogs_agent']['path']
  )
  notifies :restart, "service[#{node['awslogs_agent']['service']}]"
end

template "#{node['awslogs_agent']['path']}/bin/awslogs-agent-launcher.sh" do
  source 'var/awslogs-agent-launcher.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :user => node['awslogs_agent']['user'],
    :path => node['awslogs_agent']['path']
  )
end


if node['awslogs_agent']['databag']
  aws = data_bag_item(node['awslogs_agent']['databag'], "main")
  aws_access_key_id = aws[:aws_access_key_id]
  aws_secret_access_key = aws[:aws_secret_access_key]
else
  aws_access_key_id, aws_secret_access_key = nil
end

template "#{node['awslogs_agent']['path']}/etc/aws.conf" do
  owner 'root'
  group 'root'
  mode '0640'
  source 'etc/aws.conf.erb'
  variables(
    :region => node['awslogs_agent']['region'],
    :aws_access_key_id => aws_access_key_id,
    :aws_secret_access_key => aws_secret_access_key
  )
  notifies :restart, "service[#{node['awslogs_agent']['service']}]"
end

template "#{node['awslogs_agent']['path']}/etc/awslogs.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'etc/awslogs.conf.erb'
  variables(
    :streams => node['awslogs_agent']['streams'],
    :path => node['awslogs_agent']['path']
  )
  notifies :restart, "service[#{node['awslogs_agent']['service']}]"
end

service_provider = ''
if  'ubuntu' == node['platform']
  if Chef::VersionConstraint.new('>= 15.04').include?(node['platform_version'])
    service_provider = Chef::Provider::Service::Systemd
  elsif Chef::VersionConstraint.new('>= 12.04').include?(node['platform_version'])
    service_provider = Chef::Provider::Service::Upstart
  end
end

service node['awslogs_agent']['service'] do
  action [:enable, :start]
  provider service_provider
end

link '/var/log/awslogs.log' do
  to "/var/log/upstart/#{node['awslogs_agent']['service']}.log"
  only_if 'test -d  /var/log/upstart'
end


