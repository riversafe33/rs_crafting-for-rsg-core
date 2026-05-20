fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'riversafe'
description 'Craft System'
version '1.0'

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
}

shared_script 'config.lua'
client_scripts  {
	'dataview.lua',
	'@uiprompt/uiprompt.lua',
	'client/client.lua'
}
server_script 'server/server.lua'

