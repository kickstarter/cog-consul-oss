#!/usr/bin/env ruby

require_relative 'consul'

class CogCmd::Consul::Write < Cog::Command
  include CogCmd::Consul

  def run_command
    args = request.args
    key = args[0]
    value = args[1..-1]
    uri = URI.parse(domain + key)
    request = Net::HTTP::Put.new(uri)
    request['X-Consul-Token'] = consul_token
    request.body = value.join(' ')

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    if success(res)
      message = "\n🎉 Value associated with key successfully written."
    else
      message = "\n💔 Sorry. This key could not be written."
    end

    response['body'] = message
  end

  def success(res)
    res.code == '200'
  end
end
