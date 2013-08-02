$api_host = '192.168.0.6'

class Api # A very simple api wrapper that caches results
  require 'socket'
  require 'json'

  attr_accessor :port, :host

  def initialize(host='localhost', port=4028)
    @host, @port = host, port
  end

  def method_missing(name, *args)
    req = {command: name}
    req[:parameter] = args unless args.length == 0
    req = req.to_json

    begin
      s = TCPSocket.open(@host, @port)
      s.write req
      data = s.read.strip
      data = JSON.parse(data)
      s.close

      # Check status
      status = data['STATUS'][0]
      sc = status['STATUS']
      c = status['Code']
      msg = status['Msg']
      data.delete('STATUS')
      case sc
        when 'S'
        when 'I'
          logger.info "Info from API [#{c}]: #{msg}"
        when 'W'
          logger.info "Warning from API [#{c}]: #{msg}"
        when 'E'
          logger.fatal "Error from API [#{c}]: #{msg}"
        when 'F'
          logger.fatal "Fatal from API [#{c}]: #{msg}"
        else
          logger.fatal "Unexpected response from API '#{sc}' [#{c}]: #{msg}"
      end

      data = sanitise(data)
      return {status: :ok, code: c, message: msg, data: data}
    rescue Exception => e
      return {status: :error, error: e}
    end
  end

  def self.create
    Api.new($api_host)
  end

  private
  def sanitise(data)
    if data.is_a?(Hash)
      data.inject({}) { |n, (k, v)| n[k.downcase.gsub(' ', '_').to_sym] = sanitise(v); n }
    elsif data.is_a?(Array)
      data.map { |v| sanitise(v) }
    else
      data
    end
  end
end