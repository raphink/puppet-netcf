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
  end

  def create
  end

  def destroy
  end

  def up
  end

  def down
  end

  def definition
    ncf = Netcf.new
    i = ncf.lookup_by_name(resource[:name])
    i.xml_desc
  end

  def definition=(xml)
    ncf = Netcf.new
    i = ncf.lookup_by_name(resource[:name])
    i.define(xml)
  end

  def status
    ncf = Netcf.new
    i = ncf.lookup_by_name(resource[:name])
    if i.nil?
      :absent
    end
    if i.status == NetcfIf::ACTIVE
      :up
    else
      :down
    end
  end

end
