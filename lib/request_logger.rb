require 'logging'

class RequestLogger
  def initialize app, opts
    @app = app
    @log = opts[:log]
    @header_filter = opts[:filter] || []
    @correlation_header = opts[:correlation_header] || 'correlationId'
  end

  def call env
    env['correlation_id'] = correlation_id(env)
    Logging.mdc['correlation_id'] = correlation_id(env)
    status, response_headers, response = make_request env
    response_headers['correlation_id'] = correlation_id(env)
    [status, response_headers, response]
  end

  private

  def correlation_id env
    env['correlation_id'] || env["HTTP_#{@correlation_header.upcase}"] || SecureRandom.uuid
  end

  def make_request env
    begin
      log message: "Request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}" +
                " #{request_header_string(env)}; body: #{request_body(env)}"
      status, response_headers, response = @app.call env
    rescue Exception => e
      log level: :error, message: "Exception for #{env['REQUEST_METHOD']} #{env['PATH_INFO']} => #{e}," +
                 " #{e.backtrace[0..3].join(", ")}"
      raise e
    end
    log message: "Response: #{status} #{response_headers} #{response}"
    [status, response_headers, response]
  end

  def request_header_string env
    request_headers(env).map{|k,v| "#{k} => #{v}"}.join(' ')
  end

  def request_headers env
    env.inject({}){|acc, (k,v)| acc[$1] = v if (k =~ /^http_(.*)/i) and !(@header_filter.include?(k.to_s)) and !(@header_filter.include?($1.to_s)); acc}
  end

  def request_body env
    request = Rack::Request.new(env)
    request.post? ? read(request) : ''
  end

  def read request
    request.body.rewind
    request.body.read
  end

  def log args
    if @log && args[:message]
      @log.__send__(args[:level] || :info, args[:message])
    end
  end
end
