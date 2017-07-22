use Mix.Config

config :logger, level: :debug

config :locust, num_of_workers: 1
config :locust, num_of_requests: 10
