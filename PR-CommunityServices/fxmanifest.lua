fx_version 'cerulean'
game 'gta5'
lua54 'yes'

client_scripts {
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}

shared_scripts {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
  'config.lua'
}

ui_page 'html/index.html'

files {
  'html/index.html',
  'html/app.js',
  'html/style.css'
}
