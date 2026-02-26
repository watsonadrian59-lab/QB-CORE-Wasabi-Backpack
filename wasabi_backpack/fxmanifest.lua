-----------------For support, scripts, and more----------------
--------------- https://discord.gg/wasabiscripts  -------------
---------------------------------------------------------------
fx_version 'cerulean'
game 'gta5'
auther 'Hayabusa'
lua54 'yes'

description 'Wasabi Backpack for QB-Inventory'
version '2.1.5'

client_scripts {
    'client/**.lua'
}

server_scripts {
  'server/**.lua'
}

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua'
}

Dependencies {
  'QB-Inventory',
  'QB-Core',
  'ox_lib'
}