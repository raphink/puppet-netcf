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
        resources << new(entry)
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

  def status
  end

  def up
  end

  def down
  end

  def definition
  end

  def definition=(xml)
  end

  def ensure
  end

  def ensure=(value)
  end

end
