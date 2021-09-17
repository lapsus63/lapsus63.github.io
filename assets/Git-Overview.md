<!-- ########## Git Rebase options ########## -->
<p>
<details>
<summary>Git Rebase options.</summary>

### Default rebase commands:

```bash
git checkout mybranch
git pull --rebase origin master
# begin loop :
git add resolved-conflict-file
git rebase --continue
# end loop
git push -f
```

### Fork branch "feature" from master instead of its parent branch "develop" 

```bash
git rebase --onto master develop feature
```

### Supprimer un commit d'une branche

```bash
# E---F---G---H---I---J  topicA
# ===> E---H'---I'---J'  topicA
git rebase --onto topicA~5 topicA~3 topicA
```

### Rebase interactif

```bash
# --edit-todo: Edit the todo list during an interactive rebase.
# --interactive: Make a list of the commits which are about to be rebased. Let the user edit that list before rebasing
```

### Options utiles

```bash
# --stat ou -v : afficher les diffs (à essayer)
# --no-verify : ignorer les pre-commit hooks
# --ignore-whitespace
# --autosquash ; --no-autosquash
```

</details>
</p>



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
