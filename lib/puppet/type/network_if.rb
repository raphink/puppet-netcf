require 'puppet'

Puppet::Type.newtype(:network_if) do
  @doc = "Manages network interfaces"

  ensurable do
    defaultvalues
    
    newvalue(:up) do
      current = self.retrieve
      if current == :absent
        provider.create
      end
      unless provider.is_up?
        provider.up
      end
    end

    newvalue(:down) do
      current = self.retrieve
      if current == :absent
        provider.create
      end
      if provider.is_up?
        provider.down
      end
    end

    def insync?(is)
      return true if should == :up and is == :present and provider.is_up?
      return true if should == :down and is == :present and not provider.is_up?
    end

  end

  newparam(:name, :namevar => true) do
    desc "The interface name"
  end

  newparam(:type) do
    desc "The interface type"
    newvalues(:ethernet)
  end

  newproperty(:start_mode) do
    desc "The start mode"
    newvalues(:onboot)
  end

  newproperty(:ipv4_ips, :array_matching => :all) do
    desc "The IPv4 IPs"
  end
end
