Rackspace_NTP Cookbook
============

Installs and configures ntp. 

Requirements
------------
### Supported Operating Systems
- Debian-family Linux Distributions
- RedHat-family Linux Distributions


### Cookbooks
- rackspace_ntp::default.rb 

Attributes
----------
### Recommended tunables

* `['servers']` - (applies to NTP Servers and Clients)
  - Array, should be a list of upstream NTP servers that will be considered authoritative by the local NTP daemon. The local NTP daemon will act as a client, adjusting local time to match time data retrieved from the upstream NTP servers.

  The NTP protocol works best with at least 4 servers. The ntp daemon will disregard any server after the 10th listed, but will continue monitoring all listed servers. For more information, see [Upstream Server Time Quantity](http://support.ntp.org/bin/view/Support/SelectingOffsiteNTPServers#Section_5.3.3.) at [support.ntp.org](http://support.ntp.org).

* `['peers']` - (applies to NTP Servers ONLY)
  - Array, should be a list of local NTP peers. For more information, see [Designing Your NTP Network](http://support.ntp.org/bin/view/Support/DesigningYourNTPNetwork) at [support.ntp.org](http://support.ntp.org).

* `['restrictions']` - (applies to NTP Servers only)
  - Array, should be a list of restrict lines to define access to NTP clients on your LAN.

* `['sync_clock']` (applies to NTP Servers and Clients)
  - Boolean. Defaults to false. Forces the ntp daemon to be halted, an ntp -q command to be issued, and the ntp daemon to be restarted again on every Chef-client run. Will have no effect if drift is over 1000 seconds.

* `['sync_hw_clock']` (applies to NTP Servers and Clients)
  - Boolean. Defaults to false. On *nix-based systems, forces the 'hwclock --systohc' command to be issued on every Chef-client run. This will sync the hardware clock to the system clock.
  - Not available on Windows.

* `['listen_network']` / `['listen']`
  - String, optional attribute. Default is for NTP to listen on all addresses.
  - `['listen_network']` should be set to 'primary' to listen on the node's primary IP address as determined by ohai, or set to a CIDR (eg: '192.168.4.0/24') to listen on the last node address on that CIDR.
  - `['listen']` can be set to a specific address (eg: '192.168.4.10') instead of `[:listen_network]` to force listening on a specific address.
  - If both `['listen']` and `['listen_network']` are set then `['listen']` will always win.

### Platform specific

* `['packages']`
  - Array, the packages to install
  - Default, ntp for everything, ntpdate depending on platform. 

* `['service']`
  - String, the service to act on
  - Default, ntp, NTP, or ntpd, depending on platform

* `['varlibdir']`
  - String, the path to /var/lib files such as the driftfile.
  - Default, platform-specific location. 

* `['driftfile']`
  - String, the path to the frequency file.
  - Default, platform-specific location.

* `['conffile']`
  - String, the path to the ntp configuration file.
  - Default, platform-specific location.

* `['statsdir']`
  - String, the directory path for files created by the statistics facility.
  - Default, platform-specific location. 

* `['conf_owner'] and rackspace_ntp['conf_group']`
  - String, the owner and group of the sysconf directory files, such as /etc/ntp.conf.
  - Default, platform-specific root:root or root:wheel.

* `['var_owner'] and ['var_group']`
  - String, the owner and group of the /var/lib directory files, such as /var/lib/ntp.
  - Default, platform-specific ntp:ntp or root:wheel. 

* `['leapfile']`
  - String, the path to the ntp leapfile.
  - Default, /etc/ntp.leapseconds.

* `['sync_hw_clock']`
  - Boolean, determines if the ntpdate command is issued to sync the hardware clock
  - Default, false

* `['apparmor_enabled']`
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

The timeX.int.example.org used in these roles should be the names or IP addresses of internal NTP servers. Then simply add ntp, or `rackspace_ntp::default` to your run_list to apply the ntp daemon's configuration.

### undo recipe

If for some reason you need to stop and remove the ntp daemon, you can apply this recipe by adding `rackspace_ntp::undo` to your run_list. The undo recipe is not supported on Windows at the moment.

TESTING
-------
* See testing guidelines [here](https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md)

CONTRIBUTING
------------
* See guidelines [here](https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md)


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
