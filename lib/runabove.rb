
# Application Name : demo

class Runabove
  require "net/https"
  require "open-uri"
  require 'json'
  require 'digest/sha1'
  
  def initialize(appkey, secret, consumerkey = "")
    @appkey = appkey
    @secret = secret
    @consumerkey = consumerkey
    @baseurl = "https://api.runabove.com/1.0"
    @server_time = self.time.to_i
    @delta_time = @server_time - Time.now.to_i  
  end

  def createConsumerKey
    uri = URI.parse("https://api.runabove.com/1.0/auth/credential")
    
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, initheader = {
      'Content-Type' =>'application/json',
      'X-Ra-Application' => @appkey
    })
    toSend = {
      "accessRules" => [
          {'method'=> 'GET', 'path'=> '/*'},
          {'method'=> 'POST', 'path'=> '/*'},
          {'method'=> 'PUT', 'path'=> '/*'},
          {'method'=> 'DELETE', 'path'=> '/*'}
      ]
    }.to_json
    req.body = "#{toSend}"
    req = https.request(req)
    @consumerkey = JSON.parse(req.body)["consumerKey"]
    JSON.parse(req.body)
  end

  def time
    uri = URI.parse("https://api.runabove.com/1.0/auth/time")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.get(uri.request_uri).body
  end

  def raw_call(method, path, data = nil)
    time = Time.now.to_i + @delta_time
    body = data.nil? ? "" : data.to_json
    
    puts data.inspect 
    puts [ 
        @secret, @consumerkey, method.upcase, @baseurl + path, body, time 
      ].join("+")

    sign = "$1$" + Digest::SHA1.hexdigest([ 
        @secret, @consumerkey, method.upcase, @baseurl + path, body, time 
      ].join("+"))
   
    uri = URI.parse("#{@baseurl}#{path}")
    https = Net::HTTP.new(uri.host,uri.port)
    https.use_ssl = true
    headers = {
      'X-Ra-Timestamp' => (Time.now.to_i + @delta_time).to_s,
      'X-Ra-Application' => @appkey,
      'X-Ra-Signature' => sign,
      'X-Ra-Consumer' => @consumerkey
    }
    if(method.upcase == "GET") 
      req = Net::HTTP::Get.new(uri.path, initheader = headers)   
    end
    if(method.upcase == "POST") 
      req = Net::HTTP::Post.new(uri.path, initheader = headers)   
    end
    if(method.upcase == "PUT") 
      req = Net::HTTP::Put.new(uri.path, initheader = headers)   
    end
    if(method.upcase == "DELETE") 
      req = Net::HTTP::Delete.new(uri.path, initheader = headers)   
    end
    req.body = body
    JSON.parse(https.request(req).body) rescue ""
  end
end