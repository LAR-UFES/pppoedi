executable(
    'br.inf.ufes.lar.pppoedi',
    'Exceptions/ConnectionException.vala',
    'Exceptions/FileException.vala',
    'Exceptions/ServiceException.vala',
    'Connection.vala',
    'MainWindow.vala',
    'Application.vala',
    'Constants.vala',
    'User.vala',
    dependencies :[
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
    ],
    vala_args :['-g'],
    install : true,
    install_dir : join_paths('local', get_option('bindir'))
)
