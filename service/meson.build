executable(
    'br.inf.ufes.lar.pppoedi.service',
    '../src/Exceptions/ServiceException.vala',
    '../src/Exceptions/FileException.vala',
    'Service.vala',
    dependencies :[
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
    ],
    vala_args :['--pkg=posix', '-g'],
    install : true,
    install_dir : join_paths('local', get_option('bindir'))
)
