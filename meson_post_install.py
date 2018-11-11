#!/usr/bin/env python3

import os
import subprocess

schemadir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'share', 'glib-2.0', 'schemas')
bindir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'bin', 'indicator-kdeconnect')
libdir = os.path.join(os.environ['MESON_INSTALL_PREFIX'], 'lib', 'libindicator-kdeconnect.so')

if not os.environ.get('DESTDIR'):
	print('Compiling indicator-kdeconnect schemas on '+schemadir+'...')
	subprocess.call(['glib-compile-schemas', schemadir])
	print('Linking indicator-kdeconnect '+bindir+'...')
	subprocess.call(['ln', bindir, '/lib'])
	print('Linking libindicator-kdeconnect.so '+libdir+'...')
	subprocess.call(['ln', libdir, '/bin'])
