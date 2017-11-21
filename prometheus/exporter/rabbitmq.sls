{% from "prometheus/map.jinja" import prometheus with context %}

include:
  - prometheus.user

rabbitmq_exporter_tarball:
  archive.extracted:
    - name: {{ prometheus.exporter.rabbitmq.install_dir }}
    - source: {{ prometheus.exporter.rabbitmq.source }}
    - source_hash: {{ prometheus.exporter.rabbitmq.source_hash }}
    - user: {{ prometheus.user }}
    - group: {{ prometheus.group }}
    - archive_format: tar
    - if_missing: {{ prometheus.exporter.rabbitmq.version_path }}

rabbitmq_exporter_bin_link:
  file.symlink:
    - name: /usr/bin/rabbitmq_exporter
    - target: {{ prometheus.exporter.rabbitmq.version_path }}/rabbitmq_exporter
    - require:
      - archive: rabbitmq_exporter_tarball

rabbitmq_exporter_defaults:
  file.managed:
    - name: /etc/default/rabbitmq_exporter
    - source: salt://prometheus/files/default-rabbitmq_exporter.jinja
    - template: jinja

rabbitmq_exporter_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/rabbitmq_exporter.service
    - source: salt://prometheus/files/rabbitmq_exporter.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/rabbitmq_exporter.conf
    - source: salt://prometheus/files/rabbitmq_exporter.upstart.jinja
{%- endif %}
    - require_in:
      - file: rabbitmq_exporter_service

rabbitmq_exporter_service:
  service.running:
    - name: rabbitmq_exporter
    - enable: True
    - reload: True
    - watch:
      - file: rabbitmq_exporter_service_unit
      - file: rabbitmq_exporter_defaults
      - file: rabbitmq_exporter_bin_link
