class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init

  helper_method :app_name, :app_version, :elapsed_time, :mhash_to_s, :miner, :privileged?, :json_protect

  def init
    @start_time = Time.now
  end

  def app_name
    "PiMiner"
  end

  def app_version
    "0.1a"
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
    "#{speed.round(2)} #{units[unit]}h/s"
  end

  def miner
    @miner ||= Api.create
  end

  def json_protect
    begin
      render json: {status: :ok, result: yield}
    rescue Exception => e
      render json: {status: :err, message: e.to_s}, status: 500
    end
  end

  # Todo: login system
  def privileged?
    true && miner.privileged?
  end
end