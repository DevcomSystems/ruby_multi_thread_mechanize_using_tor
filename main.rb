#!/usr/bin/env ruby
require File.expand_path('../tor', __FILE__)
require 'socksify'

def mechanise_instance(thread_number, tor_control_port, tor_socks_port)
  # Setup your program to use the correct socks settings
  TCPSocket::socks_server = "127.0.0.1"
  TCPSocket::socks_port = tor_socks_port
  
  # Create new tor object and request new ip
  tor = Tor.new
  tor.get_new_ip_address(tor_control_port, tor_socks_port)
  
  # Create a new mechanise agent
  a = Mechanize.new do |agent|
    agent.user_agent_alias = 'Mac FireFox'
  end
  
  ipaddress = 0
  # Retreive your ip address again
  ip_page = a.get('http://get-ip.org/') do |page|
    data = page.forms.first # => Mechanize::Form
    data.fields.each { |f| ipaddress = f.value }
  end
  
  # Populate global array
  $mutex.synchronize do
    $thread_information[thread_number][:num] = thread_number
    $thread_information[thread_number][:socks_port] = tor_socks_port
    $thread_information[thread_number][:control_port] = tor_control_port
    $thread_information[thread_number][:ip] = ipaddress
  end
  puts "thread #{thread_number} done"
end

# Get command line arguments
instances = Integer("#{ARGV[0]}")

# Initialise variables
$mutex = Mutex.new # Create a global mutex for communication
threads = {}
tor_control_ports = {}
tor_socks_ports = {}
tor_control_port_start = 8119
tor_socks_port_start = 50001

# Create a global array of hashes to store the information from each thread.
$thread_information = {}
0.upto(instances-1) do |c|
  $thread_information[c] = Hash.new
end

i=0
while i < instances
  tor_control_ports[i] = tor_control_port_start + i
  tor_socks_ports[i] = tor_socks_port_start + i
  
  # Create thread
  threads[i] = Thread.new(i) do |t_i| # Create a new thread
    mechanise_instance(t_i, tor_control_ports[t_i], tor_socks_ports[t_i])
  end
  i = i + 1
end
  
# Wait for all threads to finish
0.upto(instances-1) do |t|
  puts "join thread #{t}"
  threads[t].join
end

# Confirm that it all worked
0.upto(instances-1) do |j|
  # Mutex is not required here as all threads have finsihed but I put it in for the example if you still had threads running
  $mutex.synchronize do
    puts "thread #{$thread_information[j][:num]} #{$thread_information[j][:socks_port]} #{$thread_information[j][:control_port]} #{$thread_information[j][:ip]}"
  end
end  
  