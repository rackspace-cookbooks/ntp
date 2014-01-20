#
# Cookbook Name:: rackspace_ntp
# Recipe:: default
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Tim Smith (<tsmith@limelight.com>)
# Author:: Christopher Coffey (<christopher.coffey@rackspace.com>)
#
# Copyright 2009-2013, Opscode, Inc
# Cofeyright 2014, Rackspace, US, Inc.
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

node[:rackspace_ntp][:packages].each do |ntppkg|
  package ntppkg
end

[node[:rackspace_ntp][:varlibdir], node[:rackspace_ntp][:config][:statsdir]].each do |ntpdir|
  directory ntpdir do
    owner node[:rackspace_ntp][:var_owner]
    group node[:rackspace_ntp][:var_group]
    mode  '0755'
  end
end

cookbook_file node[:rackspace_ntp][:config][:leapfile] do
  owner node[:rackspace_ntp][:conf_owner]
  group node[:rackspace_ntp][:conf_group]
  mode  '0644'
end

include_recipe 'rackspace_ntp::apparmor' if node[:rackspace_ntp][:apparmor_enabled]

unless node[:rackspace_ntp][:config][:servers].size > 0
  node.default[:rackspace_ntp][:config][:servers] = [
    '0.pool.ntp.org',
    '1.pool.ntp.org',
    '2.pool.ntp.org',
    '3.pool.ntp.org'
  ]
  log 'No NTP servers specified, using default ntp.org server pools'
end

if node[:rackspace_ntp][:config][:listen].nil? && !node[:rackspace_ntp][:listen_network].nil?
  if node[:rackspace_ntp][:listen_network] == 'primary'
    node.set[:rackspace_ntp][:config][:listen] = node[:ipaddress]
  else
    require 'ipaddr'
    net = IPAddr.new(node[:rackspace_ntp][:listen_network])

    node[:network][:interfaces].each do |iface, addrs|
      addrs[:addresses].each do |ip, params|
        addr = IPAddr.new(ip) if params[:family].eql?('inet') || params[:family].eql?('inet6')
        node.set[:rackspace_ntp][:config][:listen] = addr if net.include?(addr)
      end
    end
  end
end

template node[:rackspace_ntp][:conffile] do
  cookbook node[:rackspace_ntp][:templates_cookbook][:ntp_conf]
  source   'ntp.conf.erb'
  owner    node[:rackspace_ntp][:config][:conf_owner]
  group    node[:rackspace_ntp][:config][:conf_group]
  mode     '0644'
  notifies :restart, "service[#{node[:rackspace_ntp][:service]}]"
end

if node[:rackspace_ntp][:sync_clock]
  execute "Stop #{node[:rackspace_ntp][:service]} in preparation for ntpdate" do
    command '/bin/true'
    action :run
    notifies :stop, "service[#{node[:rackspace_ntp][:service]}]", :immediately
  end

  execute 'Force sync system clock with ntp server' do
    command 'ntpd -q'
    action :run
    notifies :start, "service[#{node[:rackspace_ntp][:service]}]"
  end
end

execute 'Force sync hardware clock with system clock' do
  command 'hwclock --systohc'
  action :run
  only_if { node[:rackspace_ntp][:sync_hw_clock] }
end

service node[:rackspace_ntp][:service] do
  supports :status => true, :restart => true
  action   [:enable, :start]
end
