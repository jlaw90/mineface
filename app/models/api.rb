class Api # A very simple api wrapper that caches results
  require 'socket'
  require 'json'

  Messages = {# Todo: define user-friendly error messages, maybe even localise
              51 => "You can't disable the only active pool",
              66 => "You can't delete the only active pool",
              67 => "Can't remove this pool as it's currently active"
  }

  attr_accessor :port, :host

  def self.create
    @@inst ||= Api.new(ENV['api_host'] || 'localhost', (ENV['api_port'] || 4028).to_i)
  end

  def privileged?
    begin
      self.privileged # Will error if we can't access privileged commands
      return true
    rescue
      return false
    end
  end

  def initialize(host, port)
    @host, @port = host, port
  end

  def query(method, *params)
    req = {command: method}
    unless params.length == 0
      params = params.map { |p| p.to_s.gsub('\\', '\\\\').gsub(',', '\,') }
      req[:parameter] = params.join(',')
    end
    req = req.to_json

    begin
      s = TCPSocket.open(@host, @port)
    rescue
      raise "Failed to connect to miner at #@host:#@port"
    end
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
      else
        raise Messages[c] || "#{c}: #{msg}"
    end

    data = sanitise(data)
    {status: :ok, code: c, message: msg, data: data}
  end

  def method_missing(name, *args)
    query(name, *args)
  end

  def version
    query('version')[:data][:version][0]
  end

  def summary
    query('summary')[:data][:summary][0]
  end

  def pools
    query('pools')[:data][:pools].each do |pool|
      pool[:status] = pool[:status].downcase.to_sym
      pool[:id] = pool[:pool]
    end
  end

  def pool(id)
    pools.keep_if { |e| e[:id] == id }.first
  end

  # Todo: this won't work if there was only one pool and the new pool is invalid... (sigh)
  def update_pool(pool)
    addpool(pool[:url], pool[:user], pool[:pass]) # Add the new one
    pools = self.pools
    new = pools.last
    new[:priority], pools[pool[:id]][:priority] = pools[pool[:id]][:priority], new[:priority]
    order = pools.sort { |a, b| a[:priority] <=> b[:priority] }.map { |p| p[:pool] }
    poolpriority(*order) # Change pool priorities
    disablepool(pool[:id]) # Disable the old pool
    sleep(0.5) # Todo: nasty hack...
    removepool(pool[:id]) # Remove the old pool
  end

  def devices
    devs = query 'devs'
    mapped = devs[:data][:devs].map do |dev|
      dev[:enabled] = dev[:enabled] == true || dev[:enabled] == 'Y'
      dev[:status] = dev[:status].downcase.to_sym
      types = [:cpu, :gpu, :pga, :asc]
      types.each do |type|
        next unless dev.has_key?(type)
        raise 'Device with multiple types' if dev.has_key?(:type)
        dev[:type] = type
        dev[:id] = dev[dev[:type]]
      end
      dev
    end
    mapped
  end

  def device(type, id)
    devices.keep_if { |e| e[:type] == type and e[:id] == id }.first
  end

  def enable_device(type, id)
    case type
      when :gpu then
        gpuenable(id)
      when :pga then
        pgaenable(id)
      when :asc then
        ascenable(id)
      else
        raise "I don't know how to enable devices of type #{type}"
    end
  end

  def disable_device(type, id)
    case type
      when :gpu then
        gpudisable(id)
      when :pga then
        pgadisable(id)
      when :asc then
        ascdisable(id)
      else
        raise "I don't know how to disable devices of type #{type}"
    end
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