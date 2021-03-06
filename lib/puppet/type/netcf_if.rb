# Provides an interface to netcf for Puppet
#
# Copyright (c) 2012, Camptocamp
# Licensed under the Apache License, Version 2.0

Puppet::Type.newtype(:netcf_if) do
  include Puppet::Util

  @doc = <<-EOT
    Configure an interface using Netcf.

    Requires:

    - [Netcf](https://fedorahosted.org/netcf/)
    - The ruby-netcf bindings

    Sample usage:

        netcf_if {"eth1":
          ensure     => up,
          definition => '
<interface type="ethernet" name="eth1">
  <start mode="onboot"/>
  <protocol family="ipv4">
     <ip address="192.168.0.5" prefix="24"/>
     <route gateway="192.168.0.1"/>
  </protocol>
</interface>
';
        }
  EOT

  newparam (:name) do
    desc "The name of the interface."
    isnamevar
  end

  newproperty (:definition) do
    desc "The definition of the interface, as an XML."

    def insync?(is)
      # Comparing XML is a bit more complex
      # than testing equality of strings
      require 'nokogiri'
      require 'equivalent-xml'
      EquivalentXml.equivalent?(@should.to_s, is.to_s, opts = { :element_order => false, :normalize_whitespace => true })
    end
  end

  newproperty(:ensure) do
    desc "Whether an interface should be up."

    newvalue(:up, :event => :interface_up) do
      @resource.provider.up
    end

    newvalue(:down, :event => :interface_down) do
      @resource.provider.down
    end

    newvalue(:absent) do
      @resource.provider.destroy
    end

    aliasvalue(:false, :absent)
    aliasvalue(:true, :up)
    aliasvalue(:present, :up)

    def retrieve
      @resource.provider.status?
    end

    def sync
      event = super()

      if property = @resource.property(:enable)
        val = property.retrieve
        property.sync unless property.safe_insync?(val)
      end

      event
    end
  end

end
