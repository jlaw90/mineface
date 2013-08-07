class PoolController < ApplicationController
  def create
    json_protect do
      url, user, pass = params.values_at(*%w(url user pass))
      miner.addpool(url, user, pass)
      nil
    end
  end

  def new
  end

  def update
    json_protect do
      id, url, user, pass = params.values_at(*%w(id url user pass))
      miner.update_pool({id: id.to_i, url: url, user: user, pass: pass})
    end
  end

  def delete
    json_protect do
      miner.removepool(params[:id].to_i)
    end
  end

  def enable
    json_protect do
      miner.enablepool(params[:id].to_i)
    end
  end

  def disable
    json_protect do
      miner.disablepool(params[:id].to_i)
    end
  end

  def up
    json_protect do
      id = params[:id].to_i
      pools = miner.pools.sort { |a, b| a[:priority] <=> b[:priority] }
      idx = pools.index { |p| p[:id] == id }
      pools[idx], pools[idx-1] = pools[idx-1], pools[idx]
      pri = pools.map { |p| p[:id] }
      miner.poolpriority(*pri)
    end
  end

  def down
    json_protect do
      id = params[:id].to_i
      pools = miner.pools.sort { |a, b| a[:priority] <=> b[:priority] }
      idx = pools.index { |p| p[:id] == id }
      pools[idx], pools[idx+1] = pools[idx+1], pools[idx]
      pri = pools.map { |p| p[:id] }
      miner.poolpriority(*pri)
    end
  end

  def show
    json_protect do
      miner.pool params[:id].to_i
    end
  end
end