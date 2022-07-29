# Git

### Git Rebase options

Default rebase commands:

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

Using cherry-picks (replay all commits from branch develop to latest commit of branch feature to target branch) :
```bash
git checkout previousver && git pull
git checkout -b feature_previousver
git cherry-pick -n develop..feature
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


### Bypass SSL checks

- GIT:

```bash
GIT_SSL_NO_VERIFY=true git clone https://....
```


### Replay history

Rejouer les commits un par un ou faire une recherche dichotomique sur les commits pour retrouver un commit qui provoque une régression :

- Aller dans Gitlab et afficher l'historique des commits sur la branche cible
- Replacer son code sur un commit particulier

```bash
git checkout [revision] .
```

- Une fois la recherche terminée, revenir sur la branche actuelle

```
git reset --hard
```

- Si une merge request correspond, il est possible de créer un revert facilement depuis Gitlab et corriger la branche revert ainsi créée.


### Using git log, git blame

Identifier la portion de code qu'on souhaite analyser et retrouver le commit correspondant :

```bash
git blame -L 10,20 path/to/file.java
git whatchanged
git log -p $commitHash
git log -n 1 --pretty=format:%s $commitHash
# blame previous version
git blame -L 10,+1 $commitHash^ -- path/to/file.java
```

### Manually squash a branch

```bash
git reset --soft HEAD~2 
# or
git reset --soft <first-commit-id>

git commit -m "new commit message"
git push -f
```

### Rename a tag

```bash
git pull
git tag new old
git tag -d old
git push origin new :old
```
