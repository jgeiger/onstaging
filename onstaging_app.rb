require "bundler/setup"
require "sinatra"
require "redis"

configure :production do
  require 'newrelic_rpm'
end

set :lock, true

get '/' do
  pair = redis.get("pair_onstaging")
  response.status = 409 if pair.blank?
  pair
end

post '/' do
  @pair_onstaging = params[:pair_onstaging]
  redis.set("pair_onstaging", @pair_onstaging)
  redis.get("pair_onstaging")
end

def redis
  @redis ||= begin
               uri = URI.parse(ENV["REDISTOGO_URL"])
               Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
             end
end
