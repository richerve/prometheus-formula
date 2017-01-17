{% from "prometheus/map.jinja" import prometheus with context %}

include:
  - prometheus.user

node_exporter_tarball:
  archive.extracted:
    - name: {{ prometheus.exporters.node.install_dir }}
    - source: {{ prometheus.exporters.node.source }}
    - source_hash: {{ prometheus.exporters.node.source_hash }}
    - user: {{ prometheus.user }}
    - group: {{ prometheus.group }}
    - archive_format: tar
    - if_missing: {{ prometheus.exporter.node.version_path }}

node_exporter_bin_link:
  file.symlink:
    - name: /usr/bin/node_exporter
    - target: {{ prometheus.exporter.node.version_path }}/node_exporter
    - require:
      - archive: node_exporter_tarball

node_exporter_defaults:
  file.managed:
    - name: /etc/default/node_exporter
    - source: salt://prometheus/files/default-node_exporter.jinja
    - template: jinja

node_exporter_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/node_exporter.service
    - source: salt://prometheus/files/node_exporter.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/node_exporter.conf
    - source: salt://prometheus/files/node_exporter.upstart.jinja
{%- endif %}
    - require_in:
      - file: node_exporter_service

node_exporter_service:
  service.running:
    - name: node_exporter
    - enable: True
    - reload: True
    - watch:
      - file: node_exporter_service_unit
      - file: node_exporter_defaults
      - file: node_exporter_bin_link
