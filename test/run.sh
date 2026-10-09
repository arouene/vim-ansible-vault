#!/bin/sh
# Run inside a container with vim and ansible-core, plugin mounted at /plugin:
#   podman run --rm -v $PWD:/plugin:ro,Z vav-test sh /plugin/test/run.sh
export HOME=/root; cd /tmp; fail=0
echo secretpw > /root/pw; cp /root/pw "/root/my pw"; cp /root/pw /root/.vp
printf '#!/bin/sh\necho secretpw\n' > /root/pwscript; chmod +x /root/pwscript
printf '#!/bin/sh\necho pwfoo\n' > /root/foo; printf '#!/bin/sh\necho pwbar\n' > /root/bar
chmod +x /root/foo /root/bar

# check NAME SETUP: vault then unvault 'a: hello'; round trip must give back hello
check() {
	printf 'a: hello\n' > t.yml
	vim -Nu NONE -es -c 'set rtp+=/plugin' -c 'runtime plugin/AnsibleVault.vim' \
		-c 'set ft=yaml' -c "$2" -c 'AnsibleVault' -c 'w! enc.yml' \
		-c 'normal! gg' -c 'AnsibleUnvault' -c 'wq! dec.yml' t.yml </dev/null >/dev/null 2>&1
	if grep -q '!vault' enc.yml && grep -qx 'a: hello' dec.yml; then echo "ok   $1"
	else echo "FAIL $1"; fail=1; fi
}
check "var with ~"          "let g:ansible_vault_password_file='~/.vp'"
check "var with space"      "let g:ansible_vault_password_file='/root/my pw'"
check "var executable"      "let g:ansible_vault_password_file='/root/pwscript'"
printf '[defaults]\nvault_password_file=/root/pwscript\n' > /root/ansible.cfg
ANSIBLE_CONFIG=/root/ansible.cfg check "ansible.cfg only" "let x=1"
ANSIBLE_VAULT_PASSWORD_FILE=/root/pw check "env password file" "let x=1"
export ANSIBLE_VAULT_IDENTITY_LIST=foo@/root/foo,bar@/root/bar ANSIBLE_VAULT_ENCRYPT_IDENTITY=bar
check "vault identities"    "let x=1"
grep -q 'AES256;bar' enc.yml || { echo "FAIL identity bar not used"; fail=1; }
exit $fail
