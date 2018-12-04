============================
Prometheus saltstack formula
============================

This repo is not maintained. I don't use Salstack anymore

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Features
========

- Install and configure prometheus server, node_exporter and alertmanager

Compatibility
=============

- prometheus >= 1.0
- saltstack = 2016.3.3

Available states
================

.. contents::
    :local:

``prometheus.server``

``prometheus.exportes.node``

``prometheus.alertmanager``

Running
=======

$ salt node state.apply prometheus

Ideas and future development
============================

Template
========

This formula was created from a cookiecutter template.

See https://github.com/richerve/saltstack-formula-cookiecutter.
