class DeviceController < ApplicationController
  def show
    json_protect do
      miner.device(params[:id].to_i)
    end
  end

  def disable
    json_protect do
      miner.disable_device(params[:id].to_i)
      nil
    end
  end

  def enable
    json_protect do
      miner.enable_device(params[:id].to_i)
      nil
    end
  end
end
