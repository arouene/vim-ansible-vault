# vim-ansible-vault

## DESCRIPTION

This plugin can be used for vaulting or unvaulting inline values of a yaml
file

## INSTALLATION

### Vundle

With vundle, just insert the line below in your vimrc file:

        Plugin 'arouene/vim-ansible-vault'

Then use the command :PluginInstall

### Vim-Plug

With vim-plug, use that syntax in your vimrc file:

        Plug 'arouene/vim-ansible-vault', { 'for': ['yaml', 'yaml.ansible'] }

And then use the command :PlugInstall

### Mapping

You can define a mapping for the commands:

        " Ansible-Vault
        nnoremap <Leader>av :AnsibleVault<CR>
        nnoremap <Leader>au :AnsibleUnvault<CR>

`ansible-vault` executable must be indenpendently installed, executable and
accessible from PATH environment.

## CONFIGURATION



## USAGE

The `ANSIBLE_VAULT_PASSWORD_FILE` environment variable must be set to a valid
file path containing the password to use with ansible-vault to decrypt or
encrypt values.

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
