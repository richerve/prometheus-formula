{% from "prometheus/map.jinja" import prometheus with context %}

include:
  - prometheus.user

alertmanager_tarball:
  archive.extracted:
    - name: {{ prometheus.alertmanager.install_dir }}
    - source: {{ prometheus.alertmanager.source }}
    - source_hash: {{ prometheus.alertmanager.source_hash }}
    - archive_format: tar
    - if_missing: {{ prometheus.alertmanager.version_path }}

alertmanager_bin_link:
  file.symlink:
    - name: /usr/bin/alertmanager
    - target: {{ prometheus.alertmanager.version_path }}/alertmanager
    - require:
      - archive: alertmanager_tarball

alertmanager_config:
  file.serialize:
    - name: {{ prometheus.alertmanager.args.config_file }}
    - user: {{ prometheus.user }}
    - group: {{ prometheus.group }}
    - dataset_pillar: prometheus:alertmanager:config

alertmanager_config:
  file.managed:
    - name: {{ prometheus.alertmanager.args.config_file }}
    - source: salt://prometheus/files/config.jinja
    - template: jinja
    - user: {{ prometheus.user }}
    - group: {{ prometheus.group }}
    - makedirs: True
    - defaults:
        data: {{ prometheus.alertmanager.config }}

alertmanager_defaults:
  file.managed:
    - name: /etc/default/alertmanager
    - source: salt://prometheus/files/default-alertmanager.jinja
    - template: jinja
    - defaults:
        config_file: {{ prometheus.alertmanager.args.config_file }}
        storage_path: {{ prometheus.alertmanager.args.storage.path }}

alertmanager_storage_path:
  file.directory:
    - name: {{ prometheus.alertmanager.args.storage.path }}
    - user: {{ prometheus.user }}
    - group: {{ prometheus.group }}
    - makedirs: True
    - watch:
      - file: alertmanager_defaults

alertmanager_service_unit:
  file.managed:
{%- if grains.get('init') == 'systemd' %}
    - name: /etc/systemd/system/alertmanager.service
    - source: salt://prometheus/files/alertmanager.systemd.jinja
{%- elif grains.get('init') == 'upstart' %}
    - name: /etc/init/alertmanager.conf
    - source: salt://prometheus/files/alertmanager.upstart.jinja
{%- endif %}
    - watch:
      - file: alertmanager_defaults
    - require_in:
      - file: alertmanager_service

alertmanager_service:
  service.running:
    - name: alertmanager
    - enable: True
    - reload: True
    - watch:
      - file: alertmanager_service_unit
      - file: alertmanager_config
      - file: alertmanager_bin_link
