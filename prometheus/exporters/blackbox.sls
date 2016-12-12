{% from "prometheus/map.jinja" import prometheus with context %}
{%- set version_path = prometheus.exporters.blackbox.install_dir ~ "/blackbox_exporter-" ~ prometheus.exporters.blackbox.version %}

include:
  - prometheus.user

blackbox_exporter_tarball:
  archive.extracted:
    - name: {{ prometheus.exporters.blackbox.install_dir }}
    - source: {{ prometheus.exporters.blackbox.source }}
    - source_hash: {{ prometheus.exporters.blackbox.source_hash }}
    - archive_format: tar
    - if_missing: {{ version_path }}

blackbox_exporter_bin_link:
  file.symlink:
    - name: /usr/bin/blackbox_exporter
    - target: {{ version_path }}/blackbox_exporter
    - require:
      - archive: blackbox_exporter_tarball

blackbox_exporter_defaults:
  file.managed:
    - name: /etc/default/blackbox_exporter
    - source: salt://prometheus/files/default-blackbox_exporter.jinja
    - template: jinja
    - defaults:
        config_file: {{ prometheus.exporters.blackbox.args.config_file }}

blackbox_exporter_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/blackbox_exporter.service
    - source: salt://prometheus/files/blackbox_exporter.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/blackbox_exporter.conf
    - source: salt://prometheus/files/blackbox_exporter.upstart.jinja
{%- endif %}
    - require_in:
      - file: blackbox_exporter_service

blackbox_exporter_service:
  service.running:
    - name: blackbox_exporter
    - enable: True
    - reload: True
    - watch:
      - file: blackbox_exporter_defaults
