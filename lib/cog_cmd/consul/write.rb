#!/usr/bin/env ruby

require_relative 'consul'

class CogCmd::Consul::Write < Cog::Command
  include CogCmd::Consul

  def run_command
    raise(Cog::Error, restircted_channels_response) if !permitted_channels.include?(current_channel)

    key = request.args[0]
    value = request.args[1..-1]
    res = post_key(key, value)

    if success(res)
      response.template = 'default'
      response['body'] = "\n🎉 Value associated with key successfully written."
    else
      raise(Cog::Error, "Error #{res.code}: 💔 Sorry. Your key could not be written.")
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
