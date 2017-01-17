{% from "prometheus/map.jinja" import prometheus with context %}

prometheus_group:
  group.present:
    - name: {{ prometheus.group }}
    - system: True

prometheus_user:
  user.present:
    - name: {{ prometheus.user }}
    - home: /var/lib/prometheus
    - gid: {{ prometheus.group }}
    - system: True
