#!/usr/bin/env python3

import os
import subprocess

schemadir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'share',
                         'glib-2.0', 'schemas')

if not os.environ.get('DESTDIR'):
    print('Compiling gsettings schemas...')
subprocess.call(['glib-compile-schemas', schemadir])

servicedir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'etc', 'systemd',
                          'system')

if not os.environ.get('DESTDIR'):
    print('Enabling PPPoEDI Service...')
subprocess.call(['systemctl', 'enable', 'br.inf.ufes.lar.pppoedi.Service'])
