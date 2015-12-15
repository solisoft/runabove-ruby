# Runabove Ruby Wrapper

Use Ruby to play with Runabove API.

## Installation

`gem install runabove`

## Usage

Creating a new consumerKey

```ruby
require "runabove"

ra = Runabove.new(YOUR_APP_KEY, YOUR_SECRET)
data = ra.createConsumerKey
puts "ConsumerKey = #{data["consumerKey"]}"
puts "To validate your consumerKey, open this link into your browser : #{data["validationUrl"]}"
```

Once you have validated your consumerKey you can do :

```ruby
ra = Runabove.new(YOUR_APP_KEY, YOUR_SECRET, A_VALIDATED_CONSUMER_KEY)
data = ra.me.info
puts data.inspect
```

Creating a New Instance (A sandbox one using Debian 7)

```ruby
res = ra.instance.create({ 
  "flavorId" => "faa2002f-9057-4fe1-8401-fed7edb34059", 
  "imageId" => "9823f3b2-21b7-4591-8179-cf9be4d0a0a8", 
  "name" => "TEST API", 
  "region" => "SBG-1", 
  "sshKeyName" => "soli" 
})
```

Listing Instances

```ruby
res = ra.instance.list
puts res.inspect
```

Deleting a created Instance

```ruby
res = ra.instance.delete("ID_OF_YOUR_INSTANCE")
```
