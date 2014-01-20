require File.expand_path('../support/helpers', __FILE__)

describe 'rackspace_ntp::undo' do
  include Helpers::Ntp

  it 'disables the NTP daemon' do
    service(node[:rackspace_ntp][:service]).wont_be_running
    service(node[:rackspace_ntp][:service]).wont_be_enabled
  end

  it 'removes the NTP packages' do
    node[:rackspace_ntp][:packages].each do |p|
      package(p).wont_be_installed
    end
  end
end
