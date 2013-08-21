class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init
  helper :donation

  around_filter do |controller, action|
    json_protect do
      action.call
    end
  end

  helper_method :app_name, :app_version, :elapsed_time, :mhash_to_s, :miner, :privileged?, :read_only, :read_only_reason

  private

  def init
    @start_time ||= Time.now
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
    "#{speed.round(2)} #{units[unit]}#{t('title.hps')}"
  end

  def miner
    @miner ||= Api.create
  end

  def json_protect(additional={})
    begin
      res = yield
      @data = {status: :ok, result: res}
      respond_to do |format|
        format.html
        format.json { render json: @data }
        format.xml { render xml: @data }
        format.all { render nothing: true }
      end unless performed?
    rescue Exception => e
      additional.merge!({backtrace: e.backtrace.join("\n")}) unless Rails.env.production?
      additional.merge!(@data) unless @data.nil?
      @data = {status: :err, message: e.message, backtrace: e.backtrace.join("\n")}.merge(additional)
      respond_to do |format|
        format.html {
          if request.local?
            raise e # Render pretty rails trace
          else
            render file: 'public/500.html', layout: false
          end
        }
        format.json { render json: @data, status: 500 }
        format.xml { render xml: @data, status: 500 }
        format.all { render nothing: true, status: 500 }
      end
    end
  end

  # Todo: login system
  def privileged?
    true && miner.privileged?
  end

  def read_only
    !privileged? or DonationHelper.donate_mode?
  end

  def read_only_reason
    case
      when !miner.available? then
        t('message.miner_unavailable')
      when !privileged? then
        t('message.no_privileges')
      when DonationHelper.donate_mode? then
        t('message.donating')
      else
        nil
    end
  end
end