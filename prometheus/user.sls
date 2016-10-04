prometheus_group:
  group.present:
    - name: prometheus

prometheus_user:
  user.present:
    - name: prometheus
    - home: /var/lib/prometheus
    - gid_from_name: True
