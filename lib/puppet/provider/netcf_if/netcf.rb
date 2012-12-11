# Netcf interface provider for Puppet
#
# Copyright (c) 2012 Camptocamp
# Licensed under the Apache License, Version 2.0

Puppet::Type.type(:netcf_if).provide(:netcf) do
  desc "Provides a Netcf interface"
  require 'netcf'

  def self.instances
    ncf = nil
#    begin
      resources = []
      ncf = Netcf.new

      ncf.list_interfaces(NetcfIf::ACTIVE).each do |name|
        i = ncf.lookup_by_name(name)
        xml = i.xml_desc
        entry = {:ensure => :up, :name => name,
                 :definition => xml}
        resources << new(entry) if entry[:definition]
      end

      ncf.list_interfaces(NetcfIf::INACTIVE).each do |name|
        i = ncf.lookup_by_name(name)
        xml = i.xml_desc
        entry = {:ensure => :down, :name => name,
                 :definition => xml}
        resources << new(entry) if entry[:definition]
      end
    
      resources
#    ensure
#      ncf.close if ncf
#    end 
  end

  def exists?
    notice "Testing if resource exists"
    ncf = Netcf.new
    ifs = ncf.list_interfaces(NetcfIf::ACTIVE | NetcfIf::INACTIVE)
    ifs.include?(resource[:name])
  end

  def create
    notice "Need to create interface"
    ncf = Netcf.new
    ncf.define(resource[:definition])
  end

  def destroy
    notice "Need to destroy interface"
    ncf = Netcf.new
    i = ncf.lookup_by_name(resource[:name])
    i.undefine
  end

  def up
    self.create
    notice "Getting interface up"
  end

  def down
    self.create
    notice "Taking interface down"
  end

  def definition
    ncf = Netcf.new
    i = ncf.lookup_by_name(resource[:name])
    i.xml_desc
  end

  def definition=(xml)
    self.create
  end

  def status?
    ncf = Netcf.new
    i = ncf.lookup_by_name(resource[:name])
    if i.nil?
      :absent
    elsif i.status == NetcfIf::ACTIVE
      :up
    else
      :down
    end
  end

end
