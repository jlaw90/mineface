class PoolController < ApplicationController
  before_filter only: [:create, :new, :update, :delete, :enable, :disable, :up, :down] do |controller|
    controller.instance_eval do
      raise read_only_reason if read_only
    end
  end

  def create
    url, user, pass = params.values_at(*%w(url user pass))
    miner.addpool(url, user, pass)
    miner.save
    nil
  end

  def new
  end

  def update
    id, url, user, pass = params.values_at(*%w(id url user pass))
    miner.update_pool({id: id.to_i, url: url, user: user, pass: pass})
    miner.save
  end

  def delete
    miner.removepool(params[:id].to_i)
    miner.save
  end

  def enable
    miner.enablepool(params[:id].to_i)
    miner.save
  end

  def disable
    miner.disablepool(params[:id].to_i)
    miner.save
  end

  def up
    id = params[:id].to_i
    pools = miner.pools.sort { |a, b| a[:priority] <=> b[:priority] }
    idx = pools.index { |p| p[:id] == id }
    pools[idx], pools[idx-1] = pools[idx-1], pools[idx]
    pri = pools.map { |p| p[:id] }
    miner.poolpriority(*pri)
  end

  def down
    id = params[:id].to_i
    pools = miner.pools.sort { |a, b| a[:priority] <=> b[:priority] }
    idx = pools.index { |p| p[:id] == id }
    pools[idx], pools[idx+1] = pools[idx+1], pools[idx]
    pri = pools.map { |p| p[:id] }
    miner.poolpriority(*pri)
  end

  def show
    miner.pool params[:id].to_i
  end
end