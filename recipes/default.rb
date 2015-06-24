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

include_recipe 'python'

python_virtualenv node['awslogs_agent']['path'] do
  action :create
  owner node['awslogs_agent']['user']
  group node['awslogs_agent']['group']
end

python_pip "pip" do
  virtualenv node['awslogs_agent']['path']
  version "6.1.1"
end

python_pip "awscli-cwlogs" do
  virtualenv node['awslogs_agent']['path']
  version node['awslogs_agent']['version']
  options "--extra-index-url=#{node['awslogs_agent']['plugin_url']}"
end

template "/etc/init/#{node['awslogs_agent']['service']}.conf" do
  owner 'root'
  group 'root'
  mode '0644'
  source 'etc/init/awslogs.conf.erb'
  variables(
    :user => node['awslogs_agent']['user'],
    :path => node['awslogs_agent']['path']
  )
  notifies :restart, "service[#{node['awslogs_agent']['service']}]"
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
  mode '0755'
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
  mode '0755'
  source 'etc/awslogs.conf.erb'
  variables(
    :streams => node['awslogs_agent']['streams'],
    :path => node['awslogs_agent']['path']
  )
  notifies :restart, "service[#{node['awslogs_agent']['service']}]"
end

service node['awslogs_agent']['service'] do
  action [:start, :enable]
  provider Chef::Provider::Service::Upstart
end

link '/var/log/awslogs.log' do
  to "/var/log/upstart/#{node['awslogs_agent']['service']}.log"
end


