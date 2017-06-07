systemdServiceConf = configuration_data()
systemdServiceConf.set('bindir', join_paths(get_option('prefix'), 'local', get_option('bindir')))
systemdServiceConf.set('project_name', project_name)
configure_file(
  input:  'br.inf.ufes.lar.pppoedi.Service.service.in',
  output: 'br.inf.ufes.lar.pppoedi.Service.service',
  configuration: systemdServiceConf,
  install: true,
  install_dir: '/etc/systemd/system',
)
