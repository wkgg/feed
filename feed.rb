require 'rss'
require 'json'
require 'rest-client'

def batch_send_requests requests
  response = RestClient.post( 
    'https://api.leancloud.cn/1.1/batch', 
    requests,
    :content_type => "application/json", :'x-avoscloud-request-sign' => ENV['X_AVOSCLOUD_REQUEST_SIGN'], :'X-AVOSCloud-Application-Id' => ENV['X_AVOSCLOUD_APPLICATION_ID'])
end

def build_requests insights
  data = []
  insights.each do|insight|
    request = {}
    request["method"] = "POST"
    request["path"] = "/1.1/classes/insights"
    request["body"] = insight

    data.push request
  end
  requests = {}
  requests["requests"] = data
  requests.to_json
end

rss = RSS::Parser.parse('http://insights.thoughtworkers.org/feed/', false)
insights = []
rss.items.each do |item|
  hash = {}
  hash['title'] = item.title
  hash['link'] = item.link
  hash['putDate'] = item.pubDate
  hash['content_encoded'] = item.content_encoded

  insights.push hash
end

requests = build_requests insights
batch_send_requests requests