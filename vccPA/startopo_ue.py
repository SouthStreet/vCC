
from mininet.link import TCLink, TCIntf, Link
from mininet.topo import Topo
import termcolor as T

# Just for some fancy color printing
def cprint(s, color, cr=True):
    """Print in color
       s: string to print
       color: color to use"""
    if cr:
        print T.colored(s, color)
    else:
        print T.colored(s, color),

        
# Topology to be instantiated in Mininet
class StarTopoUE(Topo):
    "Star topology for  experiment in Unequal condition"

    def __init__(self, n=3, cpu=None, bw_host_high=None, bw_host_low=None, bw_net=None,
                 delay=None, maxq=None, enable_ecn=None, enable_red=None,
                 show_mininet_commands=True, red_params=None, cutoff=None):
        # Add default members to class.
        super(StarTopoUE, self ).__init__()
        self.n = n
        self.cpu = cpu
        self.bw_host_high = bw_host_high
        self.bw_host_low = bw_host_low
        self.bw_net = bw_net
        self.delay = delay
        self.maxq = maxq
        self.enable_ecn = enable_ecn
        self.enable_red = enable_red
        self.red_params = red_params
        self.cutoff = cutoff
        self.show_mininet_commands = show_mininet_commands;
        
        cprint("Enable ECN: %d" % self.enable_ecn, 'green')
        cprint("Enable RED: %d" % self.enable_red, 'green')
        
        self.create_topology()

    # Create the experiment topology 
    # Set appropriate values for bandwidth, delay, 
    # and queue size 
    def create_topology(self):
        # Host and link configuration
        hconfig = {'cpu': self.cpu}

        
	# Set configurations for the topology and then add hosts etc.
        lconfig_sender_high = {'bw': self.bw_host_high, 'delay': self.delay,
                          'max_queue_size': self.maxq,
                          'show_commands': self.show_mininet_commands}
        lconfig_sender_low = {'bw': self.bw_host_low, 'delay': self.delay,
                          'max_queue_size': self.maxq,
                          'show_commands': self.show_mininet_commands}

        lconfig_receiver = {'bw': self.bw_net, 'delay': self.delay,
                            'max_queue_size': self.maxq,
                            'show_commands': self.show_mininet_commands}                            
        lconfig_switch = {'bw': self.bw_net, 'delay': self.delay,
                            'max_queue_size': self.maxq,
                            'enable_ecn': 1 if self.enable_ecn else 0,
                            'enable_red': 1 if self.enable_red else 0,
                            'red_params': self.red_params if ( (self.enable_red ) 
						and self.red_params != None) else None,
                            'show_commands': self.show_mininet_commands}                            
        
        n = self.n
        # Create the receiver
        receiver = self.addHost('h0')
        # Create the switch
        switch = self.addSwitch('s0')
        # Create the sender hosts
        hosts = []
        for i in range(n-1):
            hosts.append(self.addHost('h%d' % (i+1), **hconfig))
        # Create links between receiver and switch
	self.addLink(receiver, switch, cls=Link,
                      cls1=TCIntf, cls2=TCIntf,
                      params1=lconfig_receiver, params2=lconfig_switch)
        # Create links between senders and switch
        for i in range(n-1):
            if i < self.cutoff :
                 self.addLink(hosts[i], switch, **lconfig_sender_low)
            else :
	            self.addLink(hosts[i], switch, **lconfig_sender_high)
