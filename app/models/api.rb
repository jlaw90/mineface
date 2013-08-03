$api_host = '192.168.0.6'
$api_port = 4028

class Api # A very simple api wrapper that caches results
  require 'socket'
  require 'json'

  attr_accessor :port, :host

  def self.create
    Api.new($api_host, $api_port)
  end

  def initialize(host='localhost', port=4028)
    @host, @port = host, port
  end

  def query(method, *params)
    req = {command: method}
    req[:parameter] = params unless params.length == 0
    req = req.to_json

    begin
      s = TCPSocket.open(@host, @port)
      s.write req
      data = s.read.strip
      # Okay, nasty, can have control character.... let's strip 'em!
      data = data.chars.map { |c| c.ord >= 32 ? c : "\\u#{'%04x' % c.ord}" }.join
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

  def method_missing(name, *args)
    query(name, args)
  end

  def version
    ver = query('version')
    ver[:status] == :error ? nil : ver[:data][:version][0]
  end

  def summary
    sum = query('summary')
    sum[:status] == :error ? nil : sum[:data][:summary][0]
  end

  def pools
    pools = query 'pools'
    return [] if pools[:status] == :error
    mapped = pools[:data][:pools].map do |pool|
      pool[:status] = pool[:status].downcase.to_sym
      pool
    end
    mapped
  end

  def devices
    devs = query 'devs'
    return [] if devs[:status] == :error
    mapped = devs[:data][:devs].map do |dev|
      dev[:enabled] = dev[:enabled] == true || dev[:enabled] == 'Y'
      dev[:status] = dev[:status].downcase.to_sym
      dev[:type] = if dev.has_key?(:pga) then
                     :cpu
                   elsif dev.has_key?(:gpu) then
                     :gpu
                   else
                     dev.has_key?(:cpu) ? :cpu : :unknown
                   end
      dev
    end
    mapped
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