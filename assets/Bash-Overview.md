# Bash

<!-- ########## Bypass SSL checks ########## -->
<p>
<details>
<summary>Bypass SSL checks</summary>

- GIT:

```bash
GIT_SSL_NO_VERIFY=true git clone https://....
```

- WGET:

```bash
wget --no-check-certificate
```

- CURL:

```bash
curl -k url
curl --insecure url
```

- APT:

```bash
# Configure proxy
echo 'Acquire::http::Proxy "http://user:password@proxy.server:port/";' > /etc/apt/apt.conf.d/proxy.conf
echo 'Acquire::https::Proxy "http://user:password@proxy.server:port/";' >>  /etc/apt/apt.conf.d/proxy.conf
```

</details>
</p>

<!-- ########## Bash: Finding files (and replace) ########## -->
<p>
<details>
<summary>Replace text in files which content matches patterns from input file</summary>

```bash
# R : recursive directories
# Hil : Show matching files with paths without file content
# Z : \0 separated results (to handle files with spaces)
# -f : use ids.txt file to perform grep
grep -R -HilZ -F -f ids.txt sourcedir/ | xargs -0 sed -i 's/word/replacement/g'
```

</details>
</p>


<!-- ########## sed: Extract block of text from the same pattern as begin and end ########## -->
<p>
<details>
<summary>Extract block of text from the same pattern as begin and end (Ex. "## ")</summary>

```bash
# source: https://stackoverflow.com/questions/20943025/how-can-i-get-sed-to-quit-after-the-first-matching-address-range
sed -n '/^## /{p; :loop n; p; /^## /q; b loop}' THE_FILE
# remove empty lines:
| grep -v -e '^$'
```

</details>
</p>
