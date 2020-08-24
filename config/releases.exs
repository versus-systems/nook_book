import Config

name = "guide"

config :libcluster,
  topologies: [
    nook_book: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [
          :"nook_book@10.0.1.231",
          :"nook_book@10.0.1.65"
        ]
      ]
    ]
  ]

config :nook_book,
  cluster_role: System.get_env("CLUSTER_ROLE", "member") |> String.to_atom(),
  base_uri: "http://#{name}.nookbook.online"

config :nook_book, NookBookWeb.Endpoint,
  server: true,
  http: [port: 4000],
  url: [host: "#{name}.nookbook.online"],
  secret_key_base: "p6Ws6Q1cFzoCUjkOhiBsKwjXiRpJ/E26ryJ7tTzXVrZsavqS2RG3eznc4Mp2KubF"
