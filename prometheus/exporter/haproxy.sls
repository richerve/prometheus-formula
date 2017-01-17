{% from "prometheus/map.jinja" import prometheus with context %}

include:
  - prometheus.user

haproxy_exporter_tarball:
  archive.extracted:
    - name: {{ prometheus.exporter.haproxy.install_dir }}
    - source: {{ prometheus.exporter.haproxy.source }}
    - source_hash: {{ prometheus.exporter.haproxy.source_hash }}
    - user: {{ prometheus.user }}
    - group: {{ prometheus.group }}
    - archive_format: tar
    - if_missing: {{ prometheus.exporter.haproxy.version_path }}

haproxy_exporter_bin_link:
  file.symlink:
    - name: /usr/bin/haproxy_exporter
    - target: {{ prometheus.exporter.haproxy.version_path }}/haproxy_exporter
    - require:
      - archive: haproxy_exporter_tarball

haproxy_exporter_defaults:
  file.managed:
    - name: /etc/default/haproxy_exporter
    - source: salt://prometheus/files/default-haproxy_exporter.jinja
    - template: jinja
    - defaults:
        scrape_uri: {{ prometheus.exporter.haproxy.args.scrape_uri }}

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
      - file: haproxy_exporter_service_unit
      - file: haproxy_exporter_defaults
      - file: haproxy_exporter_bin_link
