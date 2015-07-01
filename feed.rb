require 'rss'
require 'json'
require 'rest-client'
require 'yaml'
require 'pry'

def batch_send_requests requests
  config = get_avoscloud_config
  response = RestClient.post( 
    'https://api.leancloud.cn/1.1/batch', 
    requests,
    :content_type => "application/json", :'x-avoscloud-request-sign' => config['x_avoscloud_request_sign'], :'X-AVOSCloud-Application-Id' => config['x_avoscloud_application_id']){ |response, request, result, &block|
      puts response
    }
end

def get_avoscloud_config
  File.open("config.yaml", "r") do |object|
    config = YAML::load(object)
  end
end

def build_requests insights
  data = []
  insights.each do|insight|
    request = {}
    request["method"] = "POST"
    request["path"] = "/1.1/classes/Post"
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
  hash['publishDate'] = {
                           "__type" => "Date",
                           "iso" => item.pubDate.iso8601.sub(/\+08:00/, ".123Z")
                        }
  hash['content'] = item.content_encoded
  hash['guid'] = item.guid.content
  hash['tags'] = item.categories.map {|category| category.content}
  hash['description'] = item.description

  insights.push hash
end

requests = build_requests insights
batch_send_requests requests