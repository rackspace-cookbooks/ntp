require 'spec_helper'

describe 'rackspace_ntp::undo' do
  let(:chef_run) { ChefSpec::Runner.new.converge('rackspace_ntp::undo') }

  it 'stops the ntpd service' do
    expect(chef_run).to disable_service('ntpd')
  end

  it 'sets the ntpd service not to start on boot' do
    expect(chef_run).not_to enable_service('ntpd')
  end

  it 'uninstalls the ntp package' do
    expect(chef_run).to remove_package('ntp')
  end

  it 'uninstalls the ntpdate package' do
    expect(chef_run).to remove_package('ntpdate')
  end
end
