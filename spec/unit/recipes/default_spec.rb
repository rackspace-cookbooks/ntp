require 'spec_helper'

describe 'rackspace_ntp::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge('rackspace_ntp::default') }

  it 'installs the ntp package' do
    expect(chef_run).to install_package('ntp')
  end

  it 'installs the ntpdate package' do
    expect(chef_run).to install_package('ntpdate')
  end

  context 'the varlibdir directory' do
    let(:directory) { chef_run.directory('/var/lib/ntp') }

    it 'creates the directory' do
      expect(chef_run).to create_directory('/var/lib/ntp')
    end

    it 'is owned by ntp:ntp' do
      expect(directory.owner).to eq('ntp')
      expect(directory.group).to eq('ntp')
    end

    it 'has 0755 permissions' do
      expect(directory.mode).to eq('0755')
    end
  end

  context 'the statsdir directory' do
    let(:directory) { chef_run.directory('/var/log/ntpstats/') }

    it 'creates the directory' do
      expect(chef_run).to create_directory('/var/log/ntpstats/')
    end

    it 'is owned by ntp:ntp' do
      expect(directory.owner).to eq('ntp')
      expect(directory.group).to eq('ntp')
    end

    it 'has 0755 permissions' do
      expect(directory.mode).to eq('0755')
    end
  end

  context 'the leapfile' do
    let(:cookbook_file) { chef_run.cookbook_file('/etc/ntp.leapseconds') }

    it 'creates the cookbook_file' do
      expect(chef_run).to create_cookbook_file('/etc/ntp.leapseconds')
    end

    it 'is owned by ntp:ntp' do
      expect(cookbook_file.owner).to eq('root')
      expect(cookbook_file.group).to eq('root')
    end

    it 'has 0644 permissions' do
      expect(cookbook_file.mode).to eq('0644')
    end
  end

# context 'the ntp.conf' do
#   let(:template) { chef_run.template('/etc/ntp.conf') }
#
#    it 'creates the template' do
#      expect(chef_run).to create_file('/etc/ntp.conf')
#    end
#
#    it 'is owned by root:root' do
#      expect(template.owner).to eq('root')
#      expect(template.group).to eq('root')
#    end
#
#    it 'has 0644 permissions' do
#      expect(template.mode).to eq('0644')
#    end
#  end

  it 'does not execute the "Force sync system clock with ntp server" command' do
    expect(chef_run).not_to run_execute('ntpd -q')
  end

  it 'does not execute the "Force sync hardware clock with system clock" command' do
    expect(chef_run).not_to run_execute('hwclock --systohc')
  end

  it 'starts the ntpd service' do
    expect(chef_run).to start_service('ntpd')
  end

  it 'sets ntpd to start on boot' do
    expect(chef_run).to enable_service('ntpd')
  end

  context 'the sync_clock attribute is set' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set[:rackspace_ntp][:sync_clock] = true
      runner.converge('rackspace_ntp::default')
    end

    it 'executes the "Force sync system clock with ntp server" command' do
      expect(chef_run).to run_execute('ntpd -q')
    end
  end

  context 'the sync_hw_clock attribute is set on a non-Windows OS' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set[:rackspace_ntp][:sync_hw_clock] = true
      runner.converge('rackspace_ntp::default')
    end

    it 'executes the "Force sync hardware clock with system clock" command' do
      expect(chef_run).to run_execute('hwclock --systohc')
    end
  end

  context 'ntp["listen_network"] is set to "primary"' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set[:rackspace_ntp][:listen_network] = 'primary'
      runner.converge('rackspace_ntp::default')
    end

    it 'expect ntp[:config][:listen] to be equal node[:ipaddress]' do
      expect(chef_run.node['rackspace_ntp']['config']['listen']).to eq(chef_run.node['ipaddress'])
    end
  end

  context 'ntp["listen_network"] is set to a CIDR' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['network']['interfaces']['eth0']['addresses']['192.168.253.254'] = {
        'netmask' => '255.255.255.0',
        'broadcast' => '192.168.253.255',
        'family' => 'inet'
      }
      runner.node.set[:rackspace_ntp][:listen_network] = '192.168.253.0/24'
      runner.converge('rackspace_ntp::default')
    end

    it 'expect ntp["listen"] to be the CIDR interface address' do
      expect(chef_run.node['rackspace_ntp']['config']['listen']).to eq('192.168.253.254')
    end
  end

  context 'ntp["listen"] is set to a specific address' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['ntp']['listen'] = '192.168.254.254'
      runner.converge('rackspace_ntp::default')
    end

    it 'expect ntp[:listen] to be the specified address' do
      expect(chef_run.node['ntp']['listen']).to eq('192.168.254.254')
    end
  end

  context 'ntp["listen"] and ntp["listen_network"] are both set (primary test)' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['network']['interfaces']['eth0']['addresses']['192.168.253.254'] = {
        'netmask' => '255.255.255.0',
        'broadcast' => '192.168.253.255',
        'family' => 'inet'
      }
      runner.node.set['network']['interfaces']['eth1']['addresses']['192.168.254.254'] = {
        'netmask' => '255.255.255.0',
        'broadcast' => '192.168.254.255',
        'family' => 'inet'
      }
      runner.node.set['network']['default_gateway'] = '192.168.253.1'
      runner.node.set['ntp']['listen_network'] = 'primary'
      runner.node.set['ntp']['listen'] = '192.168.254.254'
      runner.converge('rackspace_ntp::default')
    end

    it 'expect ntp["listen"] to be the specified address from ntp["listen"]' do
      expect(chef_run.node['ntp']['listen']).to eq('192.168.254.254')
    end
  end

  context 'ntp["listen"] and ntp["listen_network"] are both set (CIDR test)' do
    let(:chef_run) do
      runner = ChefSpec::Runner.new
      runner.node.set['network']['interfaces']['eth0']['addresses']['192.168.253.254'] = {
        'netmask' => '255.255.255.0',
        'broadcast' => '192.168.253.255',
        'family' => 'inet'
      }
      runner.node.set['network']['interfaces']['eth1']['addresses']['192.168.254.254'] = {
        'netmask' => '255.255.255.0',
        'broadcast' => '192.168.254.255',
        'family' => 'inet'
      }
      runner.node.set[:rackspace_ntp][:listen_network] = '192.168.253.0/24'
      runner.node.set[:rackspace_ntp][:config][:listen] = '192.168.254.254'
      runner.converge('rackspace_ntp::default')
    end

    it 'expect [:rackspace_ntp][:config][:listen] to be the specified address from ntp["listen"]' do
      expect(chef_run.node[:rackspace_ntp][:config][:listen]).to eq('192.168.254.254')
    end
  end

  context 'ubuntu' do
    let(:chef_run) { ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04').converge('rackspace_ntp::default') }

    it 'starts the ntp service' do
      expect(chef_run).to start_service('ntp')
    end

    it 'sets ntp to start on boot' do
      expect(chef_run).to enable_service('ntp')
    end

    it 'includes the apparmor recipe' do
      expect(chef_run).to include_recipe('rackspace_ntp::apparmor')
    end
  end

end
