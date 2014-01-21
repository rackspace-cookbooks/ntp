require File.expand_path('../support/helpers', __FILE__)

describe 'rackspace_ntp::default' do
  include Helpers::Ntp

  it 'starts the NTP daemon' do
    service(node['rackspace_ntp']['service']).must_be_running
    service(node['rackspace_ntp']['service']).must_be_enabled
  end

  it 'creates the leapfile' do
    file(node['rackspace_ntp']['config']['leapfile']).must_exist.with(:owner, node['rackspace_ntp']['conf_owner']).and(:group, node['rackspace_ntp']['conf_group'])
  end

  it 'creates the ntp.conf' do
    file('/etc/ntp.conf').must_exist.with(:owner, node['rackspace_ntp']['conf_owner']).and(:group, node['rackspace_ntp']['conf_group'])

    node['rackspace_ntp']['servers'].each do |s|
      file('/etc/ntp.conf').must_include s
    end
  end
end
