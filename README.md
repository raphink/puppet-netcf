# Netcf module for Puppet

**Manages network settings using the Netcf library.**

This is the Puppet netcf module.


## Rationale

Managing network interfaces cleanly using Puppet is not an easy task. Fortunately, the `netcf` library provides an OS-agnostic interface which allows to manage network settings natively through an XML-based API.

This module uses the `netcf` Ruby bindings to provide a set of types and providers for Puppet in order to cleanly manage network settings.


## Requirements

This module requires [the netcf Ruby bindings](https://github.com/raphink/netcf-ruby)

## Resources

### `netcf_if`

The `netcf_if` type is a generic type which lets you manage any kind of interface (or even more than one) by passing an XML description of it. The XML description (as per [`netcf`'s XML schema](https://git.fedorahosted.org/cgit/netcf.git/tree/tests/interface)) is passed to the `netcf` library to define the interface.

Sample usage:

```puppet
netcf_if {"eth1":
  ensure     => up,
  definition => '
<interface type="ethernet" name="eth1">
  <start mode="onboot"/>
  <protocol family="ipv4">
     <ip address="192.168.0.5" prefix="24"/>
     <route gateway="192.168.0.1"/>
  </protocol>
</interface>',
}
```


### `network_if`

The `network_if` is a type to manage simple network interfaces through the `netcf` library.

Sample usage:

```puppet
network_if { 'eth0':
  ensure     => 'down',
  type       => 'ethernet',
  start_mode => 'onboot',
  ipv4_ips   => ['192.168.1.3/24'],
}
```

## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-netcf/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-netcf/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).

## License

Copyright (c) 2014 <mailto:puppet@camptocamp.com> All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

