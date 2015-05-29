require 'rss'
require 'json'
require 'rest-client'

rss = RSS::Parser.parse('http://insights.thoughtworkers.org/feed/', false)
rss.items.each do |item|
  hash = {}
  hash['title'] = item.title
  hash['link'] = item.link
  hash['putDate'] = item.pubDate
  hash['content_encoded'] = item.content_encoded

  send_request hash.to_json
end

def send_request request
  response = RestClient.post( 
    'https://leancloud.cn/1.1/classes/insights', 
    request,
    :content_type => "application/json", :'x-avoscloud-request-sign' => "2c12a09cca51ff10ef42c190dd943bc6,1432918335", :'X-AVOSCloud-Application-Id' => '0erqjpcv2cbkk24t75wrb7l4n11avy0u1xl8fmkxi11nhlr9')
end
