# Kubernetes Overview

## Résumé des commandes utiles

```bash
# Lister les différents types d'objets:
k get pods|deployments|services|ingress|configmaps|secrets|externalsecrets|secretstores

# Afficher le statut des pods en temps réel
k get pods --watch

# Afficher le contenu détaillé d'un objet Kube
k describe deployment <name>
k describe externalsecret <name>

# Changer de contexte 
k config use-context <context-name>

# Refresh les secrets du vault mis à jour : recharger le secret puis redémarrer le pod
k annotate externalSecret <external-secret-name> force-sync=$(date +%s) --overwrite

# Redémarrer un pod
k delete pod
# ou (scale 0 puis 1)
k scale --replicas=1 deployment <pod-name>
# Détruire un pod et ne pas le redémarrer
k delete deployment

# Consulter les logs sur les 5 dernieres minutes (tester aussi 1d, 2h, ...)
k logs --since 5m -f <pod-name>
```
