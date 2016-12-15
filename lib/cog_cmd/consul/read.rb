#!/usr/bin/env ruby

require_relative 'consul'

class CogCmd::Consul::Read < Cog::Command
  include CogCmd::Consul

  def run_command
    args = request.args
    key = args[0]
    uri = URI.parse(domain + key)
    params = { :token => consul_token }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    if success(res)
      body = parse_body(res)
      message = Base64.decode64(body["Value"])
    else
      message = "\nError #{res.code}: 💔 Sorry. There was a problem processing this request."
    end

    response['body'] = message
  end

  def success(res)
    res.code == '200'
  end

  def parse_body(res)
    JSON.parse(res.body)
  end
end
