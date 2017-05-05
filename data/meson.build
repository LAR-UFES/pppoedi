install_data(
    meson.project_name() + '.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications')
)

install_data(
    meson.project_name() + '.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

install_data(
    meson.project_name() + 'Service' + '.service',
    install_dir: join_paths(get_option('datadir'), 'dbus-1', 'system-services')
)

install_data(
    meson.project_name() + '.conf',
    install_dir: join_paths(get_option('sysconfdir'), 'dbus-1', 'system.d')
)
