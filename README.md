`consul`: The Cog Consul Command Bundle
=========================================

`!consul:read`  
`!consul:write`
`!consul:list`

## Overview

The `consul` bundle adds two new commands: read and write.

* `read` - Show values associated with a key. 
        `read <key>`
        `read` is a GET call to the Consul API. It will return the value stored.

* `write` - Write values associated with a key.
        `write <key> <value>`
        `write` is a PUT call to the Consul API. It won't return anything.

* `list` - List all keys associated with an endpoint.
        `list <endpoint>`
        `list` is a GET call to the Consul API. It will return an array of keys.

## Configuration

* The consul bundle uses the [v1 Consul API](https://www.consul.io/docs/agent/http/kv.html).

Consul uses env vars to configure it. Both commands require
`CONSUL_DOMAIN_NAME` and `CONSUL_MASTER_TOKEN` to be set. These are the 
domain name for your consul account and the api token for write privledges respectively. You can find an example of how to set these configurations in the `base/example_dynamic_config.yaml`. 

Optionally, you can set `CONSUL_CHANNELS` to restrict permisible channels for `write`. 

## Install

    git clone git@github.com:kickstarter/cog-consul-oss.git
    cogctl bundle install config.yaml

## Build

To build the Docker image, simply run:

   `$ docker build .`
