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
  end

  after do
    ENV.clear
    mock_server.shutdown
    mock_server_thread.exit
  end

  context 'Consul::Write' do
    describe 'writing a value' do
      let(:command_name) { 'write' }

      it 'should create an write' do
        run_command(args: ['myKey', 'myval'])
        expect(command).to be_an_instance_of CogCmd::Consul::Write
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
        expect(command).to respond_with({"body"=>"myvalue"})
        expect(command).to respond_with_text("myvalue")
      end
    end

    describe 'error handling when no value' do
      it 'should show a helpful message on 404' do
        mock_server.mount_proc '/' do |req, res|
          res.status = 404
        end

        run_command(args: ['notMyKey'])
        expect(command).to respond_with("\nError 404: 💔 Sorry. There was a problem processing this request.")
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
        expect(command).to respond_with("body" => ["key1", "key2", "key3"])
      end
    end

    describe 'error handling when no endpoint' do
      it 'should show a helpful message on 404' do
        mock_server.mount_proc '/' do |req, res|
          res.status = 404
        end

        run_command(args: ['notMyEndpoint'])
        expect(command).to respond_with("\nError 404: 💔 Sorry. There was a problem processing this request.")
      end
    end
  end
end
