{% from "prometheus/map.jinja" import prometheus with context %}
{%- set version_path = prometheus.server.install_dir ~ "/prometheus-" ~ prometheus.server.version %}

include:
  - prometheus.user

prometheus_server_tarball:
  archive.extracted:
    - name: {{ prometheus.server.install_dir }}
    - source: {{ prometheus.server.source }}
    - source_hash: {{ prometheus.server.source_hash }}
    - archive_format: tar
    - if_missing: {{ version_path }}

prometheus_bin_link:
  file.symlink:
    - name: /usr/bin/prometheus
    - target: {{ version_path }}/prometheus
    - require:
      - archive: prometheus_server_tarball

prometheus_server_config:
  file.serialize:
    - name: {{ prometheus.server.args.config_file }}
    - user: prometheus
    - group: prometheus
    - dataset: {{prometheus.server.config}}

prometheus_defaults:
  file.managed:
    - name: /etc/default/prometheus
    - source: salt://prometheus/files/default-prometheus.jinja
    - template: jinja
    - defaults:
        config_file: {{ prometheus.server.args.config_file }}
        storage_local_path: {{ prometheus.server.args.storage.local_path }}
        web_console_libraries: {{ version_path }}/console_libraries
        web_console_templates: {{ version_path }}/consoles

{%- if prometheus.server.args.storage.local_path is defined %}
prometheus_storage_local_path:
  file.directory:
    - name: {{ prometheus.server.args.storage.local_path }}
    - user: prometheus
    - group: prometheus
    - makedirs: True
    - watch:
      - file: prometheus_defaults
{%- endif %}

prometheus_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/prometheus.service
    - source: salt://prometheus/files/prometheus.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/prometheus.conf
    - source: salt://prometheus/files/prometheus.upstart.jinja
{%- endif %}
    - watch:
      - file: prometheus_defaults
    - require_in:
      - file: prometheus_service

prometheus_service:
  service.running:
    - name: prometheus
    - enable: True
    - reload: True
    - watch:
      - file: prometheus_server_config
