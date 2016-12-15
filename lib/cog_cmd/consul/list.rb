#!/usr/bin/env ruby

require_relative 'consul'

class CogCmd::Consul::List < Cog::Command
  include CogCmd::Consul

  def run_command
    args = request.args
    key = args[0]
    uri = URI.parse(domain + key)
    params = { :recurse => true, :token => consul_token }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)

    if success(res)
      body = parse_body(res)
      keys = body.map{ |kv| kv['Key'] }
      message = format_message(keys)
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

  def format_message(keys)
    key_message = "\nKeys:\n"
    keys.each do |key|
      key_message += "🔑 " + key + "\n"
    end
    return key_message
  end
end
