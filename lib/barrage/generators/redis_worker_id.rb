require 'redis'
require 'barrage/generators/base'

class Barrage
  module Generators
    class RedisWorkerId < Base
      RACE_CONDITION_TTL = 30
      self.required_options += %w(ttl)

      def initialize(options = {})
        @worker_id = nil
        @worker_ttl = 0
        @real_ttl   = 0
        super
        @data = []
        @finalizer_proc = Finalizer.new(@data)
        ObjectSpace.define_finalizer(self, @finalizer_proc)
      end

      def generate
        now = Time.now.to_i
        if @worker_ttl - now <= 0
          @data[1] = @worker_id = renew_worker_id
          # check redis after half of real ttl
          @worker_ttl = now + ttl / 2
          @real_ttl   = now + ttl
          @data[2] = @real_ttl
        end
        @worker_id
      end
      alias_method :current, :generate

      def ttl
        options["ttl"]
      end

      def redis
        @redis ||= @data[0] = Redis.new(options["redis"] || {})
      end

      class Finalizer
        def initialize(data)
          @pid = $$
          @data = data
        end

        def call(*args)
          return if @pid != $$
          redis, worker_id, real_ttl = *@data

          if redis.is_a?(Redis) and redis.connected?
            redis.del("barrage:worker:#{worker_id}") if real_ttl > Time.now.to_i
            redis._client.disconnect
          end
        end
      end

      private

      def renew_worker_id
        if @real_ttl - Time.now.to_i - RACE_CONDITION_TTL <= 0
          @worker_id = nil
        end
        new_worker_id = redis.evalsha(
          script_sha,
          argv: [2 ** length, rand(2 ** length), @worker_id, ttl, RACE_CONDITION_TTL]
        )
        new_worker_id or raise StandardError, "Renew redis worker id failed"
        return new_worker_id.to_i
      end

      def script_sha
        @script_sha ||=
          redis.script(:load, <<-EOF.gsub(/^ {12}/, ''))
            local max_value = tonumber(ARGV[1])
            local new_worker_id = ARGV[2]
            local old_worker_id = ARGV[3]
            local ttl = tonumber(ARGV[4])
            local race_condition_ttl = tonumber(ARGV[5])
            local loop_cnt = 0

            local worker_id = nil
            local candidate_worker_id = tonumber(new_worker_id)

            if type(old_worker_id) == "string" and string.len(old_worker_id) > 0 and redis.call('EXISTS', "barrage:worker:" .. old_worker_id) == 1 then
              redis.call("EXPIRE", "barrage:worker:" .. old_worker_id, ttl + race_condition_ttl)
              worker_id = old_worker_id
            else
              while redis.call("SETNX", "barrage:worker:" .. candidate_worker_id, 1) == 0 and loop_cnt < max_value
              do
                candidate_worker_id = (candidate_worker_id + 1) % max_value
                loop_cnt = loop_cnt + 1
              end
              if loop_cnt >= max_value then
                return nil
              else
                worker_id = candidate_worker_id
              end
              redis.call("EXPIRE", "barrage:worker:" .. worker_id, ttl + race_condition_ttl)
            end
            return worker_id
          EOF
      end
    end
  end
end
