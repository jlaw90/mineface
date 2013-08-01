module ApplicationHelper
  def miner
    @miner ||= Cgminer.new
  end

  def app_name
    "PiMiner"
  end

  def app_version
    "0.1a"
  end

  def windows?
    not (RUBY_PLATFORM =~ /(win|w)32$/).nil?
  end

  def elapsed_time
    Time.now - @start_time
  end

  def mhash_to_s(speed)
    units = %w(M G T P)
    unit = 0
    while speed > 1000
      speed = speed.to_f / 1000.0
      unit += 1
    end
    "#{speed} #{units[unit]}h/s"
  end

  class Cgminer # A very simple cgminer api that caches results
    require 'socket'
    require 'json'

    attr_accessor :port, :host

    def initialize(host='localhost', port=4028)
      @host, @port = host, port

      @cache = {} # A cache of requests
    end

    def method_missing(name, *args)
      req = {:command => name, :parameter => args}.to_json
      return @cache[req] if @cache.has_key?(req) # Cached?

      s = TCPSocket.open(@host, @port)
      data = JSON.parse s.read
      s.close
      @cache[req] = data

      # Check status
      status = data[:STATUS]
      sc = status[:STATUS]
      c = status[:Code]
      msg = status[:Msg]
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

      data
    end
  end
end