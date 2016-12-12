{% from "prometheus/map.jinja" import prometheus with context %}
{%- set version_path = haproxy.exporters.haproxy.install_dir ~ "/haproxy_exporter-" ~ prometheus.exporters.haproxy.version %}

include:
  - prometheus.user

haproxy_exporter_tarball:
  archive.extracted:
    - name: {{ prometheus.exporters.haproxy.install_dir }}
    - source: {{ prometheus.exporters.haproxy.source }}
    - source_hash: {{ prometheus.exporters.haproxy.source_hash }}
    - archive_format: tar
    - if_missing: {{ version_path }}

haproxy_exporter_bin_link:
  file.symlink:
    - name: /usr/bin/haproxy_exporter
    - target: {{ version_path }}/haproxy_exporter
    - require:
      - archive: haproxy_exporter_tarball

haproxy_exporter_defaults:
  file.managed:
    - name: /etc/default/haproxy_exporter
    - source: salt://prometheus/files/default-haproxy_exporter.jinja
    - template: jinja
    - defaults:
        scrape_uri: {{ prometheus.exporters.haproxy.args.scrape_uri }}

haproxy_exporter_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/haproxy_exporter.service
    - source: salt://prometheus/files/haproxy_exporter.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/haproxy_exporter.conf
    - source: salt://prometheus/files/haproxy_exporter.upstart.jinja
{%- endif %}
    - require_in:
      - file: haproxy_exporter_service

haproxy_exporter_service:
  service.running:
    - name: haproxy_exporter
    - enable: True
    - reload: True
    - watch:
      - file: haproxy_exporter_defaults
      - file: haproxy_exporter_bin_link
