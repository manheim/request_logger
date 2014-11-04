require 'rspec'
require 'rack/test'
require_relative '../lib/request_logger'

describe RequestLogger do
  let(:rack_response) { [200, {}, "app"] }
  let(:app) { ->(env) { rack_response } }
  let(:log) { double('log', info: true) }
  let(:url) { 'http://some-url.example.org' }
  let(:env) { Rack::MockRequest.env_for(url, { :input => 'req_body', :method => 'POST',
                                               'http_test' => 'success' }) }
  let(:env2) { Rack::MockRequest.env_for(url, {}) }
  let :middleware do
    described_class.new(app, log: log)
  end

  it 'logs to the info log' do
    expect(log).to receive(:info)
    middleware.call env
  end

  it 'calls the rack app' do
    expect(app).to receive(:call).with(env).and_return(rack_response)
    middleware.call env
  end

  it 'sets a correlation id value for Logging mdc' do
    middleware.call env
    expect(Logging.mdc['correlation_id']).not_to eq nil
  end

  it 'sets unique correlation id for each request' do
    middleware.call env
    previous_correlation_id = Logging.mdc['correlation_id']
    middleware.call env2
    expect(Logging.mdc['correlation_id']).not_to eq previous_correlation_id
  end

  it 'sets correlation id in the env' do
    middleware.call env
    expect(env['correlation_id']).not_to eq nil
  end

  it 'sets correlation id in response headers' do
    status, response_headers, response = middleware.call env
    expect(response_headers['correlation_id']).not_to eq nil
  end

  it 'logs the response status, headers, and body' do
    expect(log).to receive(:info).with(include(*rack_response.map(&:to_s)))
    middleware.call env
  end

  it 'logs request method, path, headers, and body' do
    expect(log).to receive(:info).with(include(env['REQUEST_METHOD'], env['PATH_INFO'],
                                               'test => success', 'req_body'))
    middleware.call env
  end

  context 'runtime error raised' do
    let(:error_msg) { 'I can have error' }
    let(:backtrace) { ['back','trace'] }
    let(:exception) do
      e = StandardError.new(error_msg)
      e.set_backtrace(backtrace)
      e
    end
    let(:app) { ->(env) { raise exception } }
    it 'logs runtime exceptions to error' do
      expect(log).to receive(:error).with(include(env['REQUEST_METHOD'], env['PATH_INFO'],
                                                  error_msg, *backtrace))
      expect { middleware.call env }.to raise_error
    end
  end
end
