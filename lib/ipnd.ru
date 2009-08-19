#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + '/../config/boot')

class IpnProcessor
  @@incoming = SMQueue(:name => "/queue/ipn.incoming",
    :host => "mq.your-domain.com", :adapter => :StompAdapter)
  
  def call(request)
    ipn = Ipn.from_request(request)
    @@incoming.put ipn.to_xml
    [ 200, { "Content-type" => "text/plain" }, "Accepted for processing:\n#{ipn.to_xml}" ]
  end
end

ipn_processor = IpnProcessor.new
run ipn_processor