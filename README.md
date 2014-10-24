# Runabove Ruby Wrapper

Use Ruby to play with Runabove API.

## Installation

`gem install runabove`

## Usage

Creating a new consumerKey

```
require "runabove"

ra = Runabove.new(YOUR_APP_KEY, YOUR_SECRET)
data = ra.createConsumerKey
puts "ConsumerKey = #{data["consumerKey"]}"
puts "To validate your consumerKey, open this link into your browser : #{data["validationUrl"]}"
```

Once you have validated your consumerKey you can do :

```
ra = Runabove.new(YOUR_APP_KEY, YOUR_SECRET, A_VALIDATED_CONSUMER_KEY)
data = ra.raw_call("get", "/me")
puts data.inspect
```

Creating a New Instance (A sandbox one using Debian 7)

```
res = ra.raw_call("post", "/instance", { 
  "flavorId" => "faa2002f-9057-4fe1-8401-fed7edb34059", 
  "imageId" => "9823f3b2-21b7-4591-8179-cf9be4d0a0a8", 
  "name" => "TEST API", 
  "region" => "SBG-1", 
  "sshKeyName" => "soli" 
})
```

Listing Instances

```
res = ra.raw_call("get", "/instance")
puts res.inspect
```

Deleting a created Instance

```
res = ra.raw_call("delete", "/instance/ID_OF_YOUR_INSTANCE")
```