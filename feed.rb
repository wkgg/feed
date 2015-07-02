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

def get_description content
  content = /<p>(?![<|&])(.+)(<br\s\/>|<\/p>)/.match content
  description = content[0].gsub( %r{</?[^>]+?>}, '' )
  description[0...100] if description.length > 100
  description
end

def item_updated guid
  File.open("guid", "r") do |file|
    if (/p=(\d+)$/.match (guid.content))[1] > (/p=(\d+)$/.match (file.read))[1]
      File.open("guid", "w"){|f| f.puts guid.content}
    else
      return true
    end
  end
  return false
end

rss = RSS::Parser.parse('http://insights.thoughtworkers.org/feed/', false)
insights = []
rss.items.reverse.each do |item|
  hash = {}
  next if item_updated item.guid
  hash['title'] = item.title
  hash['publishDate'] = {
                           "__type" => "Date",
                           "iso" => item.pubDate.iso8601.sub(/\+08:00/, ".123Z")
                        }
  hash['content'] = item.content_encoded
  hash['guid'] = item.guid.content
  hash['tags'] = item.categories.map {|category| category.content}
  hash['description'] = get_description item.content_encoded

  insights.push hash
end
binding.pry

requests = build_requests insights