require 'puppet'
require 'netcf'
require 'rexml/document'
#require 'rexml/xpath'

Puppet::Type.type(:network_if).provide(:netcf) do
  desc "Uses netcf to manage a network interface"

  def self.instances
    ncf = Netcf.new
    ncf.list_interfaces(NetcfIf::ACTIVE).map do |name|
      x = ncf.lookup_by_name(name).xml_desc
      doc = REXML::Document.new(x)
      xml_if = doc.elements['interface']
      type = xml_if.attributes['type']
      start_mode = xml_if.elements['start'].attributes['mode']
      new(
        :ensure => :active,
        :name   => name,
        :type   => type
      )
    end
  end

  def netcf_open
    Netcf.new
  end

  def exists?
    not netcf_open.lookup_by_name(resource[:name]).nil?
  end

  def is_up?
    netcf_open.lookup_by_name(resource[:name]).status == NetcfIf::ACTIVE
  end

  def create
    ipv4_xml = resource[:ipv4_ips].map { |i|
      ip, prefix = /([0-9\.]+)\/([0-9]+)/.match(i).captures
      "<ip address=\"#{ip}\" prefix=\"#{prefix}\" />"
    }.join("      \n")
    xml = "<?xml version=\"1.0\"?>
  <interface name=\"#{resource[:name]}\" type=\"#{resource[:type]}\">
    <start mode=\"#{resource[:start_mode]}\"/>
    <protocol family=\"ipv4\">
      #{ipv4_xml}
    </protocol>
  </interface>
"
    netcf_open.define(xml)
  end

  def netcf_if (name)
    netcf_open.lookup_by_name(name)
  end

  def netcf_if_doc (name)
    xml = netcf_if(name).xml_desc
    REXML::Document.new(xml)
  end

  def destroy
    netcf_if(resource[:name]).undefine
  end

  def up
    netcf_if(resource[:name]).up
  end

  def down
    netcf_if(resource[:name]).down
  end

  def start_mode
    doc = netcf_if_doc(resource[:name])
    doc.elements['interface/start'].attributes['mode']
  end

  def ipv4_ips
    doc = netcf_if_doc(resource[:name])
    REXML::XPath.match(doc, '/interface/protocol[@family="ipv4"]/ip').map do |i|
      "#{i.attributes['address']}/#{i.attributes['prefix']}"
    end
  end

  def ipv4_ips=(ips)
    create
  end

  def start_mode=(mode)
    create
  end
end
