require 'redis'
require 'barrage/generators/base'

class Barrage
  module Generators
    class RedisWorkerId < Base
      RACE_CONDITION_TTL = 30

      def initialize(options = {})
        @worker_id = nil
        @worker_ttl = 0
        super
      end

      def generate
        now = Time.now.to_i
        if @worker_ttl - now <= 0
          @worker_id = renew_worker_id
          @worker_ttl = now + ttl / 2 # 1/2 以上過ぎたら再度取得
        end
        @worker_id
      end

      def renew_worker_id
        redis.evalsha(
          script_sha,
          argv: [2 ** length, rand(2 ** length), ttl, RACE_CONDITION_TTL]
        ).to_i
      end

      def redis
        @redis = Redis.new(options["redis"] || {})
      end

      def ttl
        options["ttl"]
      end

      private

      def script_sha
        @script_sha ||=
          redis.script(:load, <<-EOF.gsub(/^ {12}/, ''))
            local worker_id = redis.call("CLIENT", "GETNAME")

            if type(worker_id) == "string" and redis.call('EXISTS', "barrage:worker:" .. worker_id) == 1 then
              redis.call("EXPIRE", "barrage:worker:" .. worker_id, ARGV[3] + ARGV[4])
            else
              worker_id = ARGV[2]
              while redis.call("SETNX", "barrage:worker:" .. worker_id, 1) == 0
              do
                worker_id = (worker_id + 1) % ARGV[1]
              end
              redis.call("EXPIRE", "barrage:worker:" .. worker_id, ARGV[3] + ARGV[4])
              redis.call("CLIENT", "SETNAME", worker_id)
            end
            return worker_id
          EOF
      end
    end
  end
end
