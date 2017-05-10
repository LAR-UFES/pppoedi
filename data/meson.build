project_name = 'br.inf.ufes.lar.pppoedi'

# Desktop launcher and description file.
desktopconf = configuration_data()
desktopconf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
desktopconf.set('project_name', project_name)
configure_file(
  input: 'br.inf.ufes.lar.pppoedi.desktop.in',
  output: 'br.inf.ufes.lar.pppoedi.desktop',
  configuration: desktopconf,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications'),
)

# D-Bus service file.
dbusconf = configuration_data()
dbusconf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
dbusconf.set('project_name', project_name)
configure_file(
  input: 'br.inf.ufes.lar.pppoedi.Service.service.in',
  output: 'br.inf.ufes.lar.pppoedi.Service.service',
  configuration: dbusconf,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'dbus-1', 'system-services'),
)

install_data(
    project_name + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

install_data(
    'br.inf.ufes.lar.pppoedi' + '.conf',
    install_dir: join_paths(get_option('sysconfdir'), 'dbus-1', 'system.d')
)
