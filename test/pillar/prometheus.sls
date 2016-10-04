prometheus:
  server:
    config:
      scrape_configs:
        - job_name: 'prometheus'
          scrape_interval: 5s
          static_configs:
            - targets: ['localhost:9090']
        - job_name: 'node'
          scrape_interval: 5s
          static_configs:
            - targets: ['localhost:9100']
