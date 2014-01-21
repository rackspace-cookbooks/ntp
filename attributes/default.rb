#
# Cookbook Name:: rackspace_ntp
# Attributes:: default
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Tim Smith (<tsmith@limelight.com>)
# Author:: Charles Johnson (<charles@opscode.com>)
# Author:: Christopher Coffey (<christopher.coffey@rackspace.com>)
#
# Copyright 2009-2013, Opscode, Inc.
# Copyright 2014, Rackspace, US, Inc.
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

# default attributes for all platforms
default['rackspace_ntp']['config']['servers'] = []
default['rackspace_ntp']['config']['peers'] = []
default['rackspace_ntp']['config']['restrictions'] = []

default['rackspace_ntp']['templates_cookbook']['ntp_conf'] = 'rackspace_ntp'

# internal attributes
default['rackspace_ntp']['packages'] = %w(ntp ntpdate)
default['rackspace_ntp']['service'] = 'ntpd'
default['rackspace_ntp']['varlibdir'] = '/var/lib/ntp'
default['rackspace_ntp']['conffile'] = '/etc/ntp.conf'
default['rackspace_ntp']['conf_owner'] = 'root'
default['rackspace_ntp']['conf_group'] = 'root'
default['rackspace_ntp']['var_owner'] = 'ntp'
default['rackspace_ntp']['var_group'] = 'ntp'
default['rackspace_ntp']['sync_clock'] = false
default['rackspace_ntp']['sync_hw_clock'] = false
default['rackspace_ntp']['listen_network'] = nil
default['rackspace_ntp']['apparmor_enabled'] = false

default['rackspace_ntp']['config']['driftfile'] = "#{node['rackspace_ntp']['varlibdir']}/ntp.drift"
default['rackspace_ntp']['config']['statsdir'] = '/var/log/ntpstats/'
default['rackspace_ntp']['config']['leapfile'] = '/etc/ntp.leapseconds'
default['rackspace_ntp']['config']['listen'] = nil

# overrides on a platform-by-platform basis
case node['platform_family']
when 'debian'
  default['rackspace_ntp']['service'] = 'ntp'
  default['rackspace_ntp']['apparmor_enabled'] = true if node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 8.04
when 'rhel'
  default['rackspace_ntp']['packages'] = %w(ntp) if node['platform_version'].to_i < 6
end
