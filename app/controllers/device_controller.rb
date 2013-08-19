class DeviceController < ApplicationController
  def show
    miner.device(params[:type].to_sym, params[:id].to_i)
  end

  def disable
    miner.disable_device(params[:type].to_sym, params[:id].to_i)
    nil
  end

  def enable
    miner.enable_device(params[:type].to_sym, params[:id].to_i)
    nil
  end
end
