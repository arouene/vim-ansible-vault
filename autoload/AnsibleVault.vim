" ansible-vault.vim - ansible-vault wrapper to encrypt/decrypt yaml values
" Maintainer:       Aurélien Rouëné <aurelien.github.arouene@rouene.fr>
" Version:          1.0

if exists('g:autoloaded_ansible_vault')
	finish
endif
let g:autoloaded_ansible_vault = 1

" Build the ansible-vault command line. g:ansible_vault_password_file is
" passed with --vault-password-file (it can be an executable); when unset,
" ansible-vault uses its own configuration (ansible.cfg, ANSIBLE_VAULT_*).
" Returns '' if the configured password file cannot be read.
function! s:command(subcommand)
	let pwfile = get(g:, 'ansible_vault_password_file', '')
	if pwfile == ''
		return 'ansible-vault ' . a:subcommand
	endif
	let pwfile = expand(pwfile)
	if !filereadable(pwfile)
		echomsg 'password file ' . pwfile . ' cannot be read'
		return ''
	endif
	return 'ansible-vault ' . a:subcommand . ' --vault-password-file ' . shellescape(pwfile)
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
	if exists('g:ansible_vault_no_unquote') && g:ansible_vault_no_unquote
		return a:string
	endif
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

function! s:getMultilineValue(start_pos)
	let lines = []
	let end_pos = a:start_pos
	let bottom_line = line('$')
	let indent = indent(a:start_pos)
	while indent(end_pos) == indent && end_pos <= bottom_line
		let lines = lines + [trim(getline(end_pos))]
		let end_pos = end_pos + 1
	endwhile
	return [a:start_pos, end_pos - 1, join(lines, '')]
endfunction

" Encrypt the value by calling ansible-vault
function! s:encrypt(value)
	let value = s:unquote(a:value)
	let cmd = s:command('encrypt_string')
	if cmd == ''
		return ''
	endif
	let result = system(cmd, value)
	if v:shell_error || match(result, '^ERROR! ') != -1
		echomsg result
		return ''
	endif
	return result
endfunction

" Decrypt the value by calling ansible-vault
function! s:decrypt(value)
	let cmd = s:command('decrypt')
	if cmd == ''
		return -1
	endif
	let result = system(cmd, a:value)
	if match(result, '^ERROR! ') != -1
		echomsg result
		return -1
	endif
	return result
endfunction

function! AnsibleVault#Vault() abort
	if !s:checkAnsibleVault()
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
	" replace the value by the encrypted one
	let encrypted = s:encrypt(value)
	if encrypted == ''
		return
	endif
	let new_line = s:replace(line, value, encrypted)
	call append(pos, split(new_line, '\n'))
	" remove the current line, as we appended the encrypted line
	normal! dd
endfunction

function! AnsibleVault#Unvault() abort
	if !s:checkAnsibleVault()
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
	let [value_begin, value_end, encrypted_value] = s:getMultilineValue(pos+1)
	" replace the value by the unencrypted one
	let decrypted_value = s:decrypt(encrypted_value)
	if decrypted_value != -1
		let new_line = s:replace(line, value, decrypted_value)
		call setline(pos, new_line)
		" remove extra encrypted lines
		silent execute value_begin.",".value_end."d"
	endif
endfunction

" Install public commands
function! AnsibleVault#Init()
	if &modifiable
		command! -buffer AnsibleVault call AnsibleVault#Vault()
		command! -buffer AnsibleUnvault call AnsibleVault#Unvault()
	endif
endfunction
