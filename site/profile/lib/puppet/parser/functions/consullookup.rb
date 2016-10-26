module Puppet::Parser::Functions
  newfunction(:consullookup, :type => :rvalue, :arity => 1) do |args|
      consulserver = lookupvar(consulserver)
      Resolv::DNS.new(:nameserver_port => [[consulserver,8600]],
                :search => [args[0]],
                :ndots => 1)
  end
end
