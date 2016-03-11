require 'emcache/version'
require 'connection_pool'
require 'ostruct'
require 'digest/sha1'
require 'redis'
require 'logger'

class Emcache
  attr_reader :redis, :prefix, :ttl, :timeout

  STATUS_SUCCESS = 0
  STATUS_NOT_EXIST = 1
  STATUS_LOCKED = 2

  def initialize(options = {})
    parse_option(options.dup)

    @lua = {
      get: scripts('base', 'get'),
      set: scripts('base', 'set'),
      del: scripts('base', 'del')
    }
  end

  def call(method, keys, args)
    logger.debug("method: #{method} sha: #{@lua[method].sha}"\
                 " key: #{keys.inspect} args: #{args.inspect}")
    redis.with do |conn|
      begin
        ret = conn.evalsha(@lua[method].sha, keys, args)
        logger.debug("method: #{method} return: #{ret}")
        ret
      rescue Redis::CommandError => ex
        logger.debug("exception: #{ex.inspect}")
        raise ex unless ex.message.start_with? 'NOSCRIPT '

        load_script(conn, method)
        retry
      end
    end
  end

  def get(key)
    status, value = call :get, [key], [prefix, block_given? ? timeout : 0]
    if block_given? && status != STATUS_SUCCESS
      lock = value
      value = yield(key)

      _set(key, lock, value) if status == STATUS_NOT_EXIST
    end
    value
  end

  def set(key, value)
    _set(key, '*', value)
  end

  def del(key)
    call :del, [key], [prefix]
  end

  private

  attr_reader :logger

  def _set(key, lock, value)
    call :set, [key, value], [prefix, lock, ttl]
  end

  def load_script(conn, method)
    logger.debug("load script: #{method}")
    server_sha = conn.script('load', @lua[method].code)
    fail('sha mismatch') if server_sha != @lua[method].sha
  end

  def script(name)
    File.read("#{File.dirname(__FILE__)}/../scripts/#{name}.lua")
  end

  def scripts(*names)
    code = names.map { |name| script(name) }.join("\n")
    sha = Digest::SHA1.hexdigest(code)
    OpenStruct.new code: code, sha: sha
  end

  def parse_option(options)
    @prefix = options.fetch(:prefix, 'DEFAULT')
    @timeout = options.fetch(:timeout, 100)
    @ttl = options.fetch(:ttl, 0)
    @logger = Logger.new(STDOUT)
    @logger.level = options.fetch(:log_level, Logger::WARN)

    cpo_opts = { size: 5, timeout: 5 }
    cpo_opts.merge!(options.fetch(:connection_pool, {}))

    redis_opts = {}
    redis_opts.merge!(options.fetch(:redis, {}))
    @redis = ConnectionPool.new(cpo_opts) { Redis.new(redis_opts) }
  end
end
