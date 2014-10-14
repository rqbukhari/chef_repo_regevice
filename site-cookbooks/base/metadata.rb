name             'base'
maintainer       'Shaoor'
maintainer_email 'rq@regdevice.com'
license          'All rights reserved'
description      'Installs/Configures base machines uesrs settings'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
recipe           'base', 'Deafult users and groups settings'
recipe 			 'base::mysql', 'Make it easy to install mysql'

depends "sudo"
depends "apt"
depends 'openssl'
depends "mysql"
depends "database"
depends 'rbenv'
depends 'nginx'
depends 'bluepill'
depends 'logrotate'