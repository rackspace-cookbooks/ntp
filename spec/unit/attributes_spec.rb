#
# Cookbook Name:: rackspace_ntp
# Test:: attributes_spec
#
# Author:: Fletcher Nichol
# Author:: Eric G. Wolfe
# Author:: Christopher Coffey (<christopher.coffey@rackspace.com)
#
# Copyright 2012, Fletcher Nichol
# Copyright 2012, Eric G. Wolfe
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

require 'spec_helper'

describe 'ntp attributes' do
  let(:chef_run) { ChefSpec::Runner.new.converge('rackspace_ntp::default') }
  let(:ntp) { chef_run.node[:rackspace_ntp] }

  describe 'on an unknown platform' do

    it 'sets the package list to ntp & ntpdate' do
      expect(ntp['packages']).to include('ntp')
      expect(ntp['packages']).to include('ntpdate')
    end

    it 'sets the service name to ntpd' do
      expect(ntp['service']).to eq('ntpd')
    end

    it 'sets the /var/lib directory' do
      expect(ntp['varlibdir']).to eq('/var/lib/ntp')
    end

    it 'sets the driftfile to /var/lib/ntp.drift' do
      expect(ntp['config']['driftfile']).to eq('/var/lib/ntp/ntp.drift')
    end

    it 'sets the conf file to /etc/ntp.conf' do
      expect(ntp['conffile']).to eq('/etc/ntp.conf')
    end

    it 'sets the stats directory to /var/log/ntpstats/' do
      expect(ntp['config']['statsdir']).to eq('/var/log/ntpstats/')
    end

    it 'sets the conf_owner to root' do
      expect(ntp['conf_owner']).to eq('root')
    end

    it 'sets the conf_group to root' do
      expect(ntp['conf_group']).to eq('root')
    end

    it 'sets the var_owner to root' do
      expect(ntp['var_owner']).to eq('ntp')
    end

    it 'sets the var_group to root' do
      expect(ntp['var_group']).to eq('ntp')
    end

    it 'sets the leapfile to /etc/ntp.leapseconds' do
      expect(ntp['config']['leapfile']).to eq('/etc/ntp.leapseconds')
    end

    it 'sets the upstream server list in the recipe' do
      expect(ntp['config']['servers']).to include('0.pool.ntp.org')
    end

    it 'sets apparmor_enabled to false' do
      expect(ntp['apparmor_enabled']).to eq(false)
    end
  end

  describe 'on Debian-family platforms' do
    let(:chef_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04').converge('rackspace_ntp::default') }

    it 'sets the service name to ntp' do
      expect(ntp['service']).to eq('ntp')
    end
  end

  describe 'on Ubuntu' do
    let(:chef_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04').converge('rackspace_ntp::default') }

    it 'sets the apparmor_enabled attribute to true' do
      expect(ntp['apparmor_enabled']).to eq(true)
    end
  end

  describe 'on the CentOS 5 platform' do
    let(:chef_run) { ChefSpec::Runner.new(platform: 'centos', version: '5.8').converge('rackspace_ntp::default') }

    it 'sets the package list to only ntp' do
      expect(ntp['packages']).to include('ntp')
      expect(ntp['packages']).not_to include('ntpdate')
    end
  end
end
