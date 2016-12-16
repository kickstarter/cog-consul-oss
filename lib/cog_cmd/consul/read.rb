#!/usr/bin/env ruby

require_relative 'consul'

class CogCmd::Consul::Read < Cog::Command
  include CogCmd::Consul

  def run_command
    key = request.args[0]
    res = fetch_key(key)

    if success(res)
      body = parse_body(res)
      response.template = 'default'
      response['body'] = Base64.decode64(body[0]["Value"])
    else
      raise(Cog::Abort, "Error #{res.code}: 💔 Sorry. There was a problem processing this request.")
    end
  end

  def fetch_key(key)
    uri = URI.parse(domain + key)
    params = { :token => consul_token }
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri)
  end

  def success(res)
    res.code == '200'
  end

  def parse_body(res)
    JSON.parse(res.body)
  end
end
