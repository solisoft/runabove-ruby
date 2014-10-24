
# Application Name : demo

class Runabove
  require "net/https"
  require "open-uri"
  require 'json'
  require 'digest/sha1'
  
  attr_reader :me, :flavor, :image, :instance, 
              :labs, :price, :project, :region, 
              :ssh, :storage, :time, :token

  def initialize(appkey, secret, consumerkey = "")
    @appkey = appkey
    @secret = secret
    @consumerkey = consumerkey
    @baseurl = "https://api.runabove.com/1.0"
    @server_time = self.timeServer.to_i
    @delta_time = @server_time - Time.now.to_i
    self.loadObjects if self.class.to_s == "Runabove"
  end

  def loadObjects
    @me = RunaboveMe.new @appkey, @secret, @consumerkey
    @flavor = RunaboveFlavor.new @appkey, @secret, @consumerkey
    @image = RunaboveImage.new @appkey, @secret, @consumerkey
    @instance = RunaboveInstance.new @appkey, @secret, @consumerkey
    @labs = RunaboveLabs.new @appkey, @secret, @consumerkey
    @price = RunabovePrice.new @appkey, @secret, @consumerkey
    @project = RunaboveProject.new @appkey, @secret, @consumerkey
    @region = RunaboveRegion.new @appkey, @secret, @consumerkey
    @ssh = RunaboveSsh.new @appkey, @secret, @consumerkey
    @storage = RunaboveStorage.new @appkey, @secret, @consumerkey
    @time = RunaboveTime.new @appkey, @secret, @consumerkey
    @token = RunaboveToken.new @appkey, @secret, @consumerkey
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

  def timeServer
    uri = URI.parse("https://api.runabove.com/1.0/auth/time")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.get(uri.request_uri).body
  end

  def raw_call(method, path, data = nil)
    time = Time.now.to_i + @delta_time
    body = data.nil? ? "" : data.to_json
    
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
    JSON.parse(https.request(req).body) rescue https.request(req).body
  end
end

class RunaboveMe < Runabove
  def info
    raw_call("get", "/me")
  end

  def api_applications
    raw_call("get", "/me/api/application")
  end

  def api_application(id)
    raw_call("get", "/me/api/application/#{id}")
  end

  def api_delete_application(id)
    raw_call("delete", "/me/api/application/#{id}")
  end

  def api_credentials
    raw_call("get", "/me/api/credential")
  end

  def api_credential(id)
    raw_call("get", "/me/api/credential/#{id}")
  end 

  def api_delete_credential(id)
    raw_call("delete", "/me/api/credential/#{id}")
  end  

  def api_credential_application(id)
    raw_call("get", "/me/api/credential/#{id}/application")
  end 

  def ask_validation(data = { "validationType" => "sms" })
    raw_call("post", "/me/askValidation", data)
  end

  def balance
    raw_call("get", "/me/balance")
  end

  def bills
    raw_call("get", "/me/bill")
  end

  def bill(id)
    raw_call("get", "/me/bill/#{id}")
  end

  def bill_details(id)
    raw_call("get", "/me/bill/#{id}/details")
  end

  def labs
    raw_call("get", "/me/labs")
  end

  def lab(name)
    raw_call("get", "/me/labs/#{name}")
  end

  def usage
    raw_call("get", "/me/usage")
  end

  def validate(data)
    raw_call("post", "/me/validate", data)
  end
end

class RunaboveFlavor < Runabove
  def list
    raw_call("get", "/flavor")
  end

  def detail(id)
    raw_call("get", "/flavor/#{id}")
  end
end

class RunaboveImage < Runabove
  def list
    raw_call("get", "/image")
  end

  def detail(id)
    raw_call("get", "/image/#{id}")
  end
end

class RunaboveInstance < Runabove
  def list
    raw_call("get", "/instance")
  end

  def create(data)
    raw_call("post", "/instance", data)
  end

  def quota
    raw_call("get", "/instance/quota")
  end

  def detail(id)
    raw_call("get", "/instance/#{id}")
  end

  def delete(id)
    raw_call("delete", "/instance/#{id}")
  end

  def update(id, data)
    raw_call("put", "/instance/#{id}", data)
  end

  def vnc(id)
    raw_call("get", "/instance/#{id}/vnc")
  end
end

class RunaboveLabs < Runabove
  def list
    raw_call("get", "/labs")
  end

  def detail(name)
    raw_call("get", "/labs/#{name}")
  end

  def subscribe(name)
    raw_call("post", "/labs/#{name}")
  end
end

class RunabovePrice < Runabove
  def list
    raw_call("get", "/price/instance")
  end
end

class RunaboveProject < Runabove
  def list
    raw_call("get", "/project")
  end

  def create
    raw_call("post", "/project")
  end
end

class RunaboveRegion < Runabove
  def list
    raw_call("get", "/region")
  end
end

class RunaboveSsh < Runabove
  def list
    raw_call("get", "/ssh")
  end

  def create(data)
    raw_call("post", "/ssh", data)
  end

  def detail(name)
    raw_call("get", "/ssh/#{name}")
  end

  def delete(name)
    raw_call("delete", "/ssh/#{name}")
  end
end

class RunaboveStorage < Runabove
  def list
    raw_call("get", "/storage")
  end

  def create(data)
    raw_call("post", "/storage", data)
  end

  def detail(name)
    raw_call("get", "/storage/#{name}")
  end
end

class RunaboveTime < Runabove
  def now
    raw_call("get", "/time")
  end
end

class RunaboveToken < Runabove
  def list
    raw_call("get", "/token")
  end
end
