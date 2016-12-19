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

  def permitted_channels
    env_var("CONSUL_CHANNELS")
  end

  def current_channel
    env_var("COG_ROOM")
  end

  def restricted_channels_response
    "ERROR: You are trying to run a restricted command in the wrong channel. Please run this command in any of the permitted_channels: ##{permitted_channels}."
  end
end
