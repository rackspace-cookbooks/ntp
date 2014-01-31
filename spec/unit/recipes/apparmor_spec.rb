require 'spec_helper'

describe 'rackspace_ntp::apparmor' do
  let(:chef_run) { ChefSpec::Runner.new.converge('rackspace_ntp::apparmor') }

  it 'creates the apparmor file' do
    expect(chef_run).to create_cookbook_file '/etc/apparmor.d/usr.sbin.ntpd'
    file = chef_run.cookbook_file('/etc/apparmor.d/usr.sbin.ntpd')
    expect(file.owner).to eq('root')
    expect(file.group).to eq('root')
  end

  it 'restarts the apparmor service' do
    chef_run.cookbook_file('/etc/apparmor.d/usr.sbin.ntpd').should notify('service[apparmor]').to(:restart)
  end

end
