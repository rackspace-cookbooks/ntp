NTP Cookbook
============

Installs and configures ntp. 

### About Testing

In addition to providing interfaces to the ntp time service, this recipe is also designed to provide a simple community cookbook with broad cross-platform support to serve as a testing documentation reference. This cookbook utilizes [Foodcritic](http://acrmp.github.io/foodcritic/), [Test-Kitchen](https://github.com/opscode/test-kitchen), [Vagrant](http://www.vagrantup.com), [Chefspec](http://acrmp.github.io/chefspec/), [bats](https://github.com/sstephenson/bats), [Rubocop](https://github.com/bbatsov/rubocop), and [Travis-CI](https://travis-ci.org) to provide a comprehensive suite of automated test coverage.

More information on the testing strategy used in this cookbook is available in the TESTING.md file, along with information on how to use this type of testing in your own cookbooks.


Requirements
------------
### Supported Operating Systems
- Debian-family Linux Distributions
- RedHat-family Linux Distributions


### Cookbooks


Attributes
----------
### Recommended tunables

* `rackspace_ntp['servers']` - (applies to NTP Servers and Clients)
  - Array, should be a list of upstream NTP servers that will be considered authoritative by the local NTP daemon. The local NTP daemon will act as a client, adjusting local time to match time data retrieved from the upstream NTP servers.

  The NTP protocol works best with at least 4 servers. The ntp daemon will disregard any server after the 10th listed, but will continue monitoring all listed servers. For more information, see [Upstream Server Time Quantity](http://support.ntp.org/bin/view/Support/SelectingOffsiteNTPServers#Section_5.3.3.) at [support.ntp.org](http://support.ntp.org).

* `rackspace_ntp['peers']` - (applies to NTP Servers ONLY)
  - Array, should be a list of local NTP peers. For more information, see [Designing Your NTP Network](http://support.ntp.org/bin/view/Support/DesigningYourNTPNetwork) at [support.ntp.org](http://support.ntp.org).

* `rackspace_ntp['restrictions']` - (applies to NTP Servers only)
  - Array, should be a list of restrict lines to define access to NTP clients on your LAN.

* `rackspace_ntp['sync_clock']` (applies to NTP Servers and Clients)
  - Boolean. Defaults to false. Forces the ntp daemon to be halted, an ntp -q command to be issued, and the ntp daemon to be restarted again on every Chef-client run. Will have no effect if drift is over 1000 seconds.

* `rackspace_ntp['sync_hw_clock']` (applies to NTP Servers and Clients)
  - Boolean. Defaults to false. On *nix-based systems, forces the 'hwclock --systohc' command to be issued on every Chef-client run. This will sync the hardware clock to the system clock.
  - Not available on Windows.

* `rackspace_ntp["listen_network"]` / `rackspace_ntp["listen"]`
  - String, optional attribute. Default is for NTP to listen on all addresses.
  - `ntp["listen_network"]` should be set to 'primary' to listen on the node's primary IP address as determined by ohai, or set to a CIDR (eg: '192.168.4.0/24') to listen on the last node address on that CIDR.
  - `rackspace_ntp["listen"]` can be set to a specific address (eg: '192.168.4.10') instead of `rackspace_ntp["listen_network"]` to force listening on a specific address.
  - If both `rackspace_ntp["listen"]` and `rackspace_ntp["listen_network"]` are set then `rackspace_ntp["listen"]` will always win.

### Platform specific

* `rackspace_ntp['packages']`
  - Array, the packages to install
  - Default, ntp for everything, ntpdate depending on platform. 

* `rackspace_ntp['service']`
  - String, the service to act on
  - Default, ntp, NTP, or ntpd, depending on platform

* `rackspace_ntp['varlibdir']`
  - String, the path to /var/lib files such as the driftfile.
  - Default, platform-specific location. 

* `rackspace_ntp['driftfile']`
  - String, the path to the frequency file.
  - Default, platform-specific location.

* `rackspace_ntp['conffile']`
  - String, the path to the ntp configuration file.
  - Default, platform-specific location.

* `rackspace_ntp['statsdir']`
  - String, the directory path for files created by the statistics facility.
  - Default, platform-specific location. 

* `rackspace_ntp['conf_owner'] and rackspace_ntp['conf_group']`
  - String, the owner and group of the sysconf directory files, such as /etc/ntp.conf.
  - Default, platform-specific root:root or root:wheel.

* `rackspace_ntp['var_owner'] and rackspace_ntp['var_group']`
  - String, the owner and group of the /var/lib directory files, such as /var/lib/ntp.
  - Default, platform-specific ntp:ntp or root:wheel. 

* `rackspace_ntp['leapfile']`
  - String, the path to the ntp leapfile.
  - Default, /etc/ntp.leapseconds.

* rackspace_ntp['sync_hw_clock']
  - Boolean, determines if the ntpdate command is issued to sync the hardware clock
  - Default, false

* `rackspace_ntp['apparmor_enabled']`
  - Boolean, enables configuration of apparmor if set to true
  - Defaults to false and will make no provisions for apparmor.  If a
    platform is apparmor enabled by default, (currently Ubuntu)
    default will be true.


Usage
-----
### default recipe

Set up the ntp attributes in a role. For example in a base.rb role applied to all nodes:

```ruby
name 'base'
description 'Role applied to all systems'
default_attributes(
  'rackspace_ntp' => {
    'servers' => ['time0.int.example.org', 'time1.int.example.org']
  }
)
```

Then in an ntpserver.rb role that is applied to NTP servers (e.g., time.int.example.org):

```ruby
name 'ntp_server'
description 'Role applied to the system that should be an NTP server.'
default_attributes(
  'rackspace_ntp' => {
    'is_server'    => 'true',
    'servers'      => ['0.pool.ntp.org', '1.pool.ntp.org'],
    'peers'        => ['time0.int.example.org', 'time1.int.example.org'],
    'restrictions' => ['10.0.0.0 mask 255.0.0.0 nomodify notrap']
  }
)
```

The timeX.int.example.org used in these roles should be the names or IP addresses of internal NTP servers. Then simply add ntp, or `ntp::default` to your run_list to apply the ntp daemon's configuration.

### undo recipe

If for some reason you need to stop and remove the ntp daemon, you can apply this recipe by adding `ntp::undo` to your run_list. The undo recipe is not supported on Windows at the moment.



Development
-----------
This section details "quick development" steps. For a detailed explanation, see [[Contributing.md]].

1. Clone this repository from GitHub:

        $ git clone git@github.com:rackspace-cookbooks/rackspace_ntp.git

2. Create a git branch

        $ git checkout -b my_bug_fix

3. Install dependencies:

        $ bundle install

4. **Write tests**
5. Make your changes/patches/fixes, committing appropriately
6. Run the tests:
    - `bundle exec foodcritic -f any .`
    - `bundle exec rspec`
    - `bundle exec rubocop`
    - `bundle exec kitchen test`

  In detail:
    - Foodcritic will catch any Chef-specific style errors
    - RSpec will run the unit tests
    - Rubocop will check for Ruby-specific style errors
    - Test Kitchen will run and converge the recipes


License & Authors
-----------------
- Author:: Joshua Timberman (<joshua@opscode.com>)
- Author:: Christopher Coffey (<christopher.coffey@rackspace.com>)
- Contributor:: Eric G. Wolfe (<wolfe21@marshall.edu>)
- Contributor:: Fletcher Nichol (<fletcher@nichol.ca>)
- Contributor:: Tim Smith (<tsmith@limelight.com>)
- Contributor:: Charles Johnson (<charles@opscode.com>)
- Contributor:: Brad Knowles (<bknowles@momentumsi.com>)

```text
Copyright 2009-2013, Opscode, Inc.
Copyright 2012, Eric G. Wolfe
Copyright 2012, Fletcher Nichol
Copyright 2012, Webtrends, Inc.
Copyright 2013, Limelight Networks, Inc.
Copyright 2013, Brad Knowles
Copyright 2013, Brad Beam
Copyright 2014, Rackspace, US, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
