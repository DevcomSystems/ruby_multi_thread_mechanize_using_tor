require 'mechanize'
require 'net/telnet'

class Tor
  def get_new_ip_address(control_port, socks_port)
    
    def tor_switch_endpoint(control_port)
      localhost = Net::Telnet::new("Host" => "localhost", "Port" => "#{control_port}", "Timeout" => 10, "Prompt" => /250 OK\n/)
      localhost.cmd('AUTHENTICATE ""') { |c| print c; throw "Cannot authenticate to Tor" if c != "250 OK\n" }
      localhost.cmd('signal NEWNYM') { |c| print c; throw "Cannot switch Tor to new route" if c != "250 OK\n" }
      localhost.close
    end

    # Navigate to http://get-ip.org/ and scrape your ip address
    def get_current_ip_address(socks_port)
      TCPSocket::socks_server = "127.0.0.1"
      TCPSocket::socks_port = socks_port
      ret = "0"
      ip_a = Mechanize.new
      ip_page = ip_a.get('http://get-ip.org/') do |page|
        endform = page.forms.first # => Mechanize::Form
        endform.fields.each { |f| ret = f.value }
      end
      return ret
    end

    def get_new_ip(control_port, socks_port)
      old_ip_address = get_current_ip_address(socks_port)
      tor_switch_endpoint(control_port)
      sleep 5 # wait for connection
      new_ip_address = get_current_ip_address(socks_port)
  
      if (old_ip_address != new_ip_address) # Compare your old ip with your current one
        puts "ip changed from " + old_ip_address + " to " + new_ip_address
        return true
      else
        puts "ip same " + old_ip_address
        return false
      end
    end

    # Infinite loop until you have retreived a different ip address to the one you started with
    until get_new_ip(control_port, socks_port)
    end
  end
  
end