require 'uri'
require 'net/https'

class Ipn
  attr_accessor :attributes
  cattr_accessor :authentication_uri
  self.authentication_uri = "https://www.paypal.com:443/cgi-bin/webscr?cmd=_notify-validate"

  class << self
    def from_xml(xml)
      new((Hash.from_xml(xml)['ipn']))
    end

    def from_request(request)
      new Rack::Request.new(request).params
    end
  end

  def initialize(attributes = {})
    @attributes = HashWithIndifferentAccess.new(attributes)
  end

  def status
    @status ||= begin
      uri = URI.parse(self.class.authentication_uri)
      payload = to_query
      request = Net::HTTP::Post.new("#{uri.path}?#{uri.query}")
      request['Content-Length'] = payload.size.to_s
      http = Net::HTTP.new(uri.host, uri.port)
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
      request = http.request(request, payload)
      request.body.downcase.to_sym
    end
  end

  def valid?
    [ :verified ].include? status
  end

  def to_query
    @attributes.keys.collect { |k| "#{k}=#{@attributes[k]}" }.join('&')
  end

  def to_xml
    @attributes.to_xml(:root => "ipn")
  end
  
  def [](key)
    @attributes[key]
  end
  
  def []=(key, value)
    @attributes[key] = value
  end
end
