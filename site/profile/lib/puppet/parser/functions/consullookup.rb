module Puppet::Parser::Functions
  newfunction(:consullookup, :type => :rvalue, :arity => 1) do |args|
      consulserver = lookupvar(consulserver)
      Resolv::DNS.new(:nameserver_port => [[consulserver,8600]],
                :ndots => 1)
      ip = A.getaddress(args[0])
      ip.to_s
  end
end
