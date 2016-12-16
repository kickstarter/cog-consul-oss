#!/usr/bin/env ruby

require_relative 'consul'

class CogCmd::Consul::List < Cog::Command
  include CogCmd::Consul

  def run_command
    endpoint = request.args[0]
    res = fetch_keys(endpoint)

    if success(res)
      body = parse_body(res)
      keys = format_keys(body)
      response.template = 'default'
      response['body'] = keys
    else
      raise(Cog::Abort, "\nError #{res.code}: 💔 Sorry. There was a problem processing this request.")
    end
  end

  def fetch_keys(endpoint)
    uri = URI.parse(domain + endpoint)
    params = { :recurse => true, :token => consul_token }
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri)
  end

  def success(res)
    res.code == '200'
  end

  def parse_body(res)
    JSON.parse(res.body)
  end

  def format_keys(body)
    message = "\n"
    body.each{ |kv| message << '🔑 ' + kv['Key'].to_s + "\n" }
    message
  end
end
