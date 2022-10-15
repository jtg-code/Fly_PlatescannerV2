fx_version 'bodacious'
game 'gta5'

author 'Fly'
description 'Speedcamera Script'
version '2.1'

lua54 'on'

shared_script '@es_extended/imports.lua'

client_scripts {
    '@es_extended/locale.lua',
	'config.lua',
	'Notify.lua',
	'locales/*.lua',
	'client/*.lua'
}

server_scripts {
    '@es_extended/locale.lua',
	'config.lua',
	'server/*.lua',
    'locales/*.lua',
	'@oxmysql/lib/MySQL.lua'
}


ui_page "html/index.html"
files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/*.png',
	'html/fonts/*.otf'
}

escrow_ignore {
    "config.lua",
    "locales/*.lua",
    "html/*.html",
    "html/*.css",
    "html/fonts/*.otf"
}
