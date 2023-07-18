# Bash

###  SSL: Bypass checks

GIT:

```bash
GIT_SSL_NO_VERIFY=true git clone https://....
```

WGET:

```bash
wget --no-check-certificate
```

CURL:

```bash
curl -k url
curl --insecure url
```

npm:

```bash
npm config set proxy "http://proxy-xxxx.com"
```

APT:

```bash
# Configure proxy
echo 'Acquire::http::Proxy "http://user:password@proxy.server:port/";' > /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Proxy "http://user:password@proxy.server:port/";' >>  /etc/apt/apt.conf.d/proxy.conf
```

### SSL: Setup keys between servers

On local machine:
```bash
# Generate a key if necessary
ssh-keygen -t rsa
# Option 1: setup id as authorized key to the local server from the local machine (prompted fro password):
ssh-copy-id -i ~/.ssh/id_rsa.pub YOUR_USER_NAME@IP_ADDRESS_OF_THE_SERVER
# option 2:
cat ~/.ssh/id_rsa.pub
```

On remote machine (option 2):
```bash
mkdir -p /home/user_name/.ssh && touch /home/user_name/.ssh/authorized_keys
vim /home/user_name/.ssh/authorized_keys
# ssh-rsa AA.... username@hostname
chmod 700 /home/user_name/.ssh && chmod 600 /home/user_name/.ssh/authorized_keys
```


### Strings: Replace text in files which content matches patterns from input file

```bash
# R : recursive directories
# Hil : Show matching files with paths without file content
# Z : \0 separated results (to handle files with spaces)
# -f : use ids.txt file to perform grep
grep -R -HilZ -F -f ids.txt sourcedir/ | xargs -0 sed -i 's/word/replacement/g'
```

### Strings: Extract block of text from the same pattern as begin and end (Ex. "## ")

```bash
# source: https://stackoverflow.com/questions/20943025/how-can-i-get-sed-to-quit-after-the-first-matching-address-range
sed -n '/^## /{p; :loop n; p; /^## /q; b loop}' THE_FILE
# remove empty lines:
| grep -v -e '^$'
```

### Strings: Use Windows clipboard (git bash)

```bash
# Paste clipboard as script argument, and store the result to the clipboard
./myscript.sh $(powershell -command "Get-Clipboard") | clip
```
