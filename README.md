NTP Cookbook
============
[![Build Status](https://secure.travis-ci.org/opscode-cookbooks/ntp.png?branch=master)](http://travis-ci.org/opscode-cookbooks/ntp)

Installs and configures ntp, optionally configure ntpdate on debian family platforms.  On Windows systems it uses the Meinberg port of the standard NTPd client to Windows.

### About the refactor
This recipe was heavily re-factored as a Hackday exercise at Chefconf 2012. The purpose of refactoring was to have a simple community cookbook which serves as a testing documentation reference.  We chose a lightweight testing method using minitest to validate the sanity of our default attributes.

More information on our testing strategy used in this cookbook is available in the TESTING.  Along with information on how to use this type of lightweight testing in your own cookbooks.

#### IMPORTANT NOTES
Breaking changes are the absence of an ntp::disable/ntp::ntpdate recipe.  This was factored out into an ntp::undo corresponding to the default recipe.


Requirements
------------
### Operating Systems
- Debian-family Linux Distributions
- RedHat-family Linux Distributions
- FreeBSD
- Windows

### Cookbooks
- When running on Windows based systems the node must include the Windows cookbook. This cookbook suggests the Windows cookbook in the metadata so as to not force including the  Windows cookbook on *nix systems. You can change the suggests to depends if you require Windows platform support


Attributes
----------
### Recommended tunables

* `ntp['servers']` - (applies to NTP Servers and Clients)

  - Array, should be a list of upstream NTP public servers.  The NTP protocol
    works best with at least 3 servers.  The NTPD maximum is 7 upstream
    servers, any more than that and some of them will be ignored by the daemon.

* `ntp['peers']` (applies to NTP Servers ONLY)

  - Array, should be a list of local NTP private servers.  Configuring peer
    servers on your LAN will reduce traffic to upstream time sources, and
    provide higher availability of NTP on your LAN.  Again the maximum is 7
    peers

* `ntp['restrictions']` (applies to NTP Servers only)

  - Array, should be a list of restrict lines to restrict access to NTP
    clients on your LAN.

### Platform specific

* `ntp['packages']`

  - Array, the packages to install
  - Default, ntp for everything, ntpdate depending on platform. Not applicable for
    Windows nodes

* `ntp['service']`

  - String, the service to act on
  - Default, ntp, NTP, or ntpd, depending on platform

* `ntp['conffile']`

  - String, the path to the ntp configuration file.
  - Default, platform-specific location.

* `ntp['driftfile']`

  - String, the path to the frequency file.
  - Default, platform-specific location.

* `ntp['varlibdir']`

  - String, the path to /var/lib files such as the driftfile.
  - Default, platform-specific location. Not applicable for Windows nodes

* `ntp['statsdir']`

  - String, the directory path for files created by the statistics facility.
  - Default, platform-specific location. Not applicable for Windows nodes

* `ntp['conf_owner'] and ntp['conf_group']`

  - String, the owner and group of the sysconf directory files, such as /etc/ntp.conf.
  - Default, platform-specific root:root or root:wheel.

* `ntp['var_owner'] and ntp['var_group']`

  - String, the owner and group of the /var/lib directory files, such as /var/lib/ntp.
  - Default, platform-specific ntp:ntp or root:wheel.  Not applicable for Windows nodes

* `ntp['package_url']`

  - String, the URL to the the Meinberg NTPd client installation package.
  - Default, Meinberg site download URL
  - Windows platform only

* `ntp['vs_runtime_url']`

  - String, the URL to the the Visual Studio C++ 2008 runtime libraries that are required
    for the Meinberg NTP client.
  - Default, Microsoft site download URL
  - Windows platform only

* `ntp['vs_runtime_productname']`

  - String, the installation name of the Visual Studio C++ Runtimes file.
  - Default, "Microsoft Visual C++ 2008 Redistributable - x86 9.0.21022"
  - Windows platform only


Usage
-----
### default recipe

Set up the ntp attributes in a role. For example in a base.rb role applied to all nodes:

```ruby
name 'base'
description 'Role applied to all systems'
default_attributes(
  'ntp' => {
    'servers' => ['time0.int.example.org', 'time1.int.example.org']
  }
)
```

Then in an ntpserver.rb role that is applied to NTP servers (e.g., time.int.example.org):

```ruby
name 'ntp_server'
description 'Role applied to the system that should be an NTP server.'
default_attributes(
  'ntp' => {
    'is_server'    => 'true',
    'servers'      => ['0.pool.ntp.org', '1.pool.ntp.org'],
    'peers'        => ['time0.int.example.org', 'time1.int.example.org'],
    'restrictions' => ['10.0.0.0 mask 255.0.0.0 nomodify notrap']
  }
)
```

The timeX.int.example.org used in these roles should be the names or IP addresses of internal NTP servers. Then simply add ntp, or `ntp::default` to your run_list to apply the ntp daemon's configuration.

### undo recipe

If for some reason you need to stop and remove the ntp daemon, you can apply this recipe by adding `ntp::undo` to your run_list.  The undo recipe is not supported on Windows at the moment.


Development
-----------
This section details "quick development" steps. For a detailed explanation, see [[Contributing.md]].

1. Clone this repository from GitHub:

        $ git clone git@github.com:opscode-cookbooks/ntp.git

2. Create a git branch

        $ git checkout -b my_bug_fix

3. Install dependencies:

        $ bundle install

4. Make your changes/patches/fixes, committing appropiately
5. **Write tests**
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
- Contributor:: Eric G. Wolfe (<wolfe21@marshall.edu>)
- Contributor:: Fletcher Nichol (<fletcher@nichol.ca>)
- Contributor:: Tim Smith (<tsmith@limelight.com>)

```text
Copyright 2009-2011, Opscode, Inc.
Copyright 2012, Eric G. Wolfe
Copyright 2012, Fletcher Nichol
Copyright 2012, Webtrends, Inc.
Copyright 2013, Limelight Networks, Inc.

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
