require_relative 'spec_helper'

describe 'CogCmd::Consul' do
  let(:encoded_value) { Base64.encode64('myvalue') }
  let(:mock_value) do
    [{
      'CreateIndex' => 97,
      'ModifyIndex' => 97,
      'Key' => 'myKey',
      'Flags' => 0,
      'Value' => encoded_value
    }]
  end

  let(:mock_endpoint) do
    [
      {
        'CreateIndex' => 97,
        'ModifyIndex' => 97,
        'Key' => 'key1',
        'Flags' => 0,
        'Value' => encoded_value
      },
      {
        'CreateIndex' => 97,
        'ModifyIndex' => 97,
        'Key' => 'key2',
        'Flags' => 0,
        'Value' => encoded_value
      },
      {
        'CreateIndex' => 97,
        'ModifyIndex' => 97,
        'Key' => 'key3',
        'Flags' => 0,
        'Value' => encoded_value
      }
    ]
  end

  let(:mock_server) do
    server = WEBrick::HTTPServer.new(
      Port: 0,
      Logger: WEBrick::Log.new("/dev/null"),
      AccessLog: [],
    )
    server
  end

  let(:mock_server_thread) { Thread.new { mock_server.start } }

  before do
    mock_server_thread
    ENV['CONSUL_DOMAIN_NAME'] = "http://localhost:#{mock_server.config[:Port]}/"
    ENV['CONSUL_TOKEN'] = 'fake-token'
    ENV['CONSUL_CHANNELS'] = 'fake-channel'
    ENV['COG_ROOM'] = 'fake-channel'
  end

  after do
    ENV.clear
    mock_server.shutdown
    mock_server_thread.exit
  end

  context 'env vars' do 
    let(:command_name) { 'read' }
    describe 'required env variables' do
      it 'should throw error if missing' do
        ENV['CONSUL_DOMAIN_NAME'], ENV['CONSUL_TOKEN'] = nil, nil

        mock_server.mount_proc '/' do |req, res|
          res.body = mock_value.to_json
        end

        expect {
          run_command(args: ['myKey'])
        }.to raise_error(Cog::Error)
      end
    end
  end

  context 'Consul:Write' do 
    let(:command_name) { 'write' }
    describe 'writing a key' do
      it 'should not allow you to run outside restricted_channels' do
        ENV['COG_ROOM'] = 'wrong-fake-channel'

        mock_server.mount_proc '/' do |req, res|
          res.body = mock_value.to_json
        end

        expect {
          run_command(args: ['myKey', 'myValue'])
        }.to raise_error(Cog::Error)
      end
    end
  end

  context 'Consul::Read' do
    let(:command_name) { 'read' }
    describe 'getting a key' do
      it 'should show a value' do
        mock_server.mount_proc '/' do |req, res|
          res.body = mock_value.to_json
        end

        run_command(args: ['myKey'])
        expect(command).to respond_with({"body"=>"Value: myvalue"})
        expect(command).to respond_with_text("Value: myvalue")
      end
    end

    describe 'error handling when no value' do
      it 'should show a helpful message on 404' do
        mock_server.mount_proc '/' do |req, res|
          res.status = 404
        end

        expect {
          run_command(args: ['notMyKey'])
        }.to raise_error(Cog::Error)
      end
    end
  end

  context 'Consul::List' do
    let(:command_name) { 'list' }

    describe 'listing keys for an endpoint' do
      it 'should show keys' do
        mock_server.mount_proc '/' do |req, res|
          res.body = mock_endpoint.to_json
        end

        run_command(args: ['myendpoint'])
        expect(command).to respond_with("body" => "\n🔑 key1\n🔑 key2\n🔑 key3")
      end
    end

    describe 'error handling when no endpoint' do
      it 'should show a helpful message on 404' do
        mock_server.mount_proc '/' do |req, res|
          res.status = 404
        end
  
        expect {
          run_command(args: ['notMyEndpoint'])
        }.to raise_error(Cog::Error)
      end
    end
  end
end
