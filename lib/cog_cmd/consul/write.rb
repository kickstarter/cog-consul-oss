#!/usr/bin/env ruby

require_relative 'consul'

class CogCmd::Consul::Write < Cog::Command
  include CogCmd::Consul

  def run_command
    key = request.args[0]
    value = request.args[1..-1]
    res = post_key(key, value)

    if success(res)
      response.content = "\n🎉 Value associated with key successfully written."
    else
      response.content = "\n💔 Sorry. This key could not be written."
    end
  end

  def post_key(key, value)
    uri = URI.parse(domain + key)
    request = Net::HTTP::Put.new(uri)
    request['X-Consul-Token'] = consul_token
    request.body = value.join(' ')

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    return res
  end

  def success(res)
    res.code == '200'
  end
end
