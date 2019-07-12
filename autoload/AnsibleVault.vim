" ansible-vault.vim - ansible-vault wrapper to encrypt/decrypt yaml values
" Maintainer:       Aurélien Rouëné <aurelien.github.arouene@rouene.fr>
" Version:          1.0

if exists('g:autoloaded_ansible_vault')
	finish
endif
let g:autoloaded_ansible_vault = 1

"Check if the password file can be found
function! s:checkPasswordFile()
	let password_file = expand(get(environ(), 'ANSIBLE_VAULT_PASSWORD_FILE', '~/.vault_password'))
	if password_file == ''
		echomsg 'ANSIBLE_VAULT_PASSWORD_FILE is not defined'
		return 0
	endif
	if !filereadable(password_file)
		echomsg 'file ANSIBLE_VAULT_PASSWORD_FILE cannot be read'
		return 0
	endif
	return 1
endfunction

" Check if ansible-vault can be found and executed
function! s:checkAnsibleVault()
	if !executable('ansible-vault')
		echomsg 'ansible-vault not found or not executable'
		return 0
	endif
	return 1
endfunction

" Remove single quotes, double quotes, spaces, tabs
function! s:unquote(string)
	return trim(a:string, '	 "''')
endfunction

" Replace a substring without regex
function! s:replace(str, match, sub)
	let pat = '\V'.escape(a:match, '\')
	let sub = escape(a:sub, '&\')
	return substitute(a:str, pat, sub, '')
endfunction

function! s:getValue()
	let pos = line('.')
	let line = getline(pos)
	let value = matchstr(line, '\v^\s*[^:]*: \zs(.*)\ze$')
	return [pos, line, value]
endfunction

function! AnsibleVault#Vault() abort
	if !s:checkPasswordFile() || !s:checkAnsibleVault()
		return
	endif
	let [pos, line, value] = s:getValue()
	if value == ""
		echomsg 'No value to encrypt'
		return
	endif
	if match(value, '!vault') != -1
		return
	endif
	if match(value, '\v^\s+\|\s*$') != -1
		" TODO: implement multiline
		echomsg 'Multiline not supported'
		return
	endif
	let original_value = value
	let value = s:unquote(value)
	" encrypt value
	let res = system('ansible-vault encrypt_string', value)
	" replace the value by the encrypted one
	let new_line = s:replace(line, original_value, res)
	call append(pos, split(new_line, '\n'))
	normal! dd
endfunction

function! AnsibleVault#Unvault() abort
	if !s:checkPasswordFile() || !s:checkAnsibleVault()
		return
	endif
	let [pos, line, value] = s:getValue()
	if value == ""
		echomsg 'No value to decrypt'
		return
	endif
	if match(value, '!vault') == -1
		return
	endif
	let lines = []
	let original_pos = pos
	let pos = pos + 1
	let indent = indent(pos)
	while indent(pos) == indent
		let lines = lines + [trim(getline(pos))]
		let pos = pos + 1
	endwhile
	" decrypt value
	let res = system('ansible-vault decrypt', join(lines, ''))
	" replace the value by the unencrypted one
	let new_line = s:replace(line, value, res)
	call setline(original_pos, new_line)
	" remove extra encrypted lines
	let encrypted_begin = original_pos + 1
	let encrypted_end = pos - 1
	silent execute encrypted_begin.",".encrypted_end."d"
endfunction

" Install public commands
function! AnsibleVault#Init()
	if &modifiable
		command! -buffer AnsibleVault call AnsibleVault#Vault()
		command! -buffer AnsibleUnvault call AnsibleVault#Unvault()
	endif
endfunction
