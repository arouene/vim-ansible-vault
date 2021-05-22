" ansible-vault.vim - ansible-vault wrapper to encrypt/decrypt yaml values
" Maintainer:       Aurélien Rouëné <aurelien.github.arouene@rouene.fr>
" Version:          1.0

if exists('g:loaded_ansible_vault')
	finish
endif
let g:loaded_ansible_vault = 1

augroup AnsibleVault
	autocmd!
	autocmd FileType yaml
		\ call AnsibleVault#Init()
	autocmd FileType yaml.ansible
		\ call AnsibleVault#Init()
augroup END
