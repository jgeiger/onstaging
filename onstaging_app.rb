require "bundler/setup"
require "sinatra"
require "redis"

configure :production do
  require 'newrelic_rpm'
end

REDIS_URI = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => REDIS_URI.host, :port => REDIS_URI.port, :password => REDIS_URI.password)

get '/' do
  pair = REDIS.get("pair_onstaging")
  response.status = 409 if pair.empty?
  pair
end

post '/' do
  @pair_onstaging = params[:pair_onstaging]
  REDIS.set("pair_onstaging", @pair_onstaging)
  REDIS.get("pair_onstaging")
end
