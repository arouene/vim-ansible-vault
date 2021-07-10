# vim-ansible-vault

## DESCRIPTION

This plugin can be used for vaulting or unvaulting inline values of a yaml
file

## INSTALLATION

### Vundle

With vundle, just insert the line below in your vimrc file:

        Plugin 'arouene/vim-ansible-vault'

Then use the command `:PluginInstall`

### Vim-Plug

With vim-plug, use that syntax in your vimrc file:

        Plug 'arouene/vim-ansible-vault', { 'for': ['yaml', 'yaml.ansible'] }

And then use the command `:PlugInstall`

### Keybindings

You can define a mapping for the `AnsibleVault` and `AnsibleUnvault` commands:

        " Ansible-Vault
        nnoremap <Leader>av :AnsibleVault<CR>
        nnoremap <Leader>au :AnsibleUnvault<CR>

The `ansible-vault` executable must be indenpendently installed, and accessible
from the PATH environment.

## CONFIGURATION

You can use configuration to customize behavior of vim-ansible-vault.

| Variable                        | Default            | Description                                            |
| ------------------------------- | ------------------ | ------------------------------------------------------ |
| `g:ansible_vault_no_unquote`    | 0                  | Set to 1 to avoid triming quotes from decoded values   |
| `g:ansible_vault_password_file` | ~/.vault_password  | Password file to use                                   |

## USAGE

A password file is used by the commands `:AnsibleVault` and `:AnsibleUnvault`
to respectively encrypt and decrypt the value of a yaml `key: value`. You first
have to set which file your are using to store your password. To do that you
can set the variable `g:ansible_vault_password_file` in your *vimrc*, or you
can set an environment variable `ANSIBLE_VAULT_PASSWORD_FILE`. If neither are
set, by default *vim-ansible-vault* will try to read the `~/.vault_password`
file.

Using the variable `g:ansible_vault_password_file` enables you to change it
from within vim, using keybinding or autogroup to switch between multiple
password files.

Password files are in plaintext, I have plans to add a support to use commands
to retrieve a password (eg. using pass or gopass), let me know if you are
interested.

In the yaml file, place the cursor on a `key: value` yaml pair then execute
the command `:AnsibleVault`. The encrypted value will replace the unencrypted
value.

To decrypt a value, in the yaml file, place the cursor on a `key: value` where
value is `!vault |` then execute the command `:AnsibleUnvault`. The decrypted
value will replace the crypted one.

### COMMANDS

These commands are only defined when the buffer is a yaml file.

**:AnsibleVault** Encrypt the value of a key: value yaml pair under the cursor.

**:AnsibleUnvault** Decrypt a vaulted value of a key: value yaml pair under the cursor.

## LIMITATIONS

Ansible-vault plugin does not use a complete Yaml parser, as such the cursor
must be standing on the 'key: value' line when using the commands. For the
same reason the key must not contains the ':' character, even if the Yaml
specifications allows it.

For now, there is no support for **vault-id**.
