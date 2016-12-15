#!/usr/bin/env ruby

require 'cog/command'
require 'net/http'
require 'uri'
require 'base64'

module CogCmd::Consul
  def domain
    env_var("CONSUL_DOMAIN_NAME", required: true)
  end

  def consul_token
    env_var("CONSUL_TOKEN", required: true)
  end
end
