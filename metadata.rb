name              'rackspace_ntp'
maintainer        'Rackspace, US, Inc.'
maintainer_email  'rackspace-cookbooks@rackspace.com'
license           'Apache 2.0'
description       'Installs and configures ntp as a client or server'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '2.0.0'

recipe 'rackspace_ntp', 'Installs and configures ntp either as a server or client'
