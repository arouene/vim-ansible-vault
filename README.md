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
| `g:ansible_vault_password_file` | (unset)            | Password file (or executable) passed to ansible-vault |

## USAGE

By default *vim-ansible-vault* lets `ansible-vault` find the password itself,
so `ansible.cfg` (`vault_password_file`, `vault_identity_list`) and the
`ANSIBLE_VAULT_PASSWORD_FILE`, `ANSIBLE_VAULT_IDENTITY_LIST` and
`ANSIBLE_VAULT_ENCRYPT_IDENTITY` environment variables work as on the command
line, including multiple vault ids.

To override that from vim, set `g:ansible_vault_password_file` in your *vimrc*.
It is passed to `ansible-vault` as `--vault-password-file` (`~` and `$VAR` are
expanded). You can change it from within vim, using keybinding or autogroup to
switch between multiple password files.

A password file is plaintext, or an executable script that prints the password
to stdout (eg. using pass or gopass), which `ansible-vault` runs itself.

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

