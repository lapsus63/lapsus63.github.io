# Kubernetes Overview

## Configuration de projet


<p>
<details>
<summary>Arborescence .k8s</summary>
```
.k8s
├───base
│       deployment.yml
│       issuer.yml
│       kustomization.yml
│       service.yml
└───overlays
    ├───dev
    │       external-secret-application-json.yml
    │       ingress.yml
    │       kubectl_config
    │       kubectl_config.local
    │       kustomization.yml
    │       secret-store.yml
    │       
    └───...
```
</details>

<p>
<details>
<summary>deployment.yml</summary>

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-name
  namespace: app_namespace
spec:
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  selector:
    matchLabels:
      app: c3po-kafka-int
  template:
    metadata:
      name: app-name
      labels:
        app: app-name
    spec:
      containers:
        - image: image_placeholder
          name: app-name
          startupProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8080
            failureThreshold: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8080
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8080
          resources:
            limits:
              cpu: 500m
              memory: 1024Mi
            requests:
              cpu: 250m
              memory: 512Mi
          env:
            - name: SPRING_APPLICATION_JSON
              valueFrom:
                secretKeyRef:
                    name: app-name-secret-spring-application-json
                    key: SPRING_APPLICATION_JSON
            - name: JAVA_VM_ARGS
              valueFrom:
                secretKeyRef:
                  name: app-name-secret-spring-application-json
                  key: JAVA_VM_ARGS
```
</details>


<p>
<details>
<summary>issuer.yml</summary>

```yaml
apiVersion: issuer.url
kind: MksPrivateIssuerClaim
metadata:
  name: app-name-issuer
  namespace: app_namespace
spec:
  genericEmail: project_author_email
```
</details>


<p>
<details>
<summary>kustomization.yml</summary>

```yaml
resources:
  - deployment.yml
  - service.yml
  - issuer.yml

... in overlays:
kind: Kustomization

resources:
  - ../../base
  - external-secret-application-json.yml
  - ingress.yml
  - secret-store.yml

# replace app_placeholder by effective environment namespace
patches:
  - patch : |-
      - op: replace
        path: /metadata/namespace
        value: dev_namespace
    target:
      namespace: app_namespace
```
</details>


<p>
<details>
<summary>service.yml</summary>

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: app-name-svc
  namespace: app_namespace
spec:
  ports:
    - port: 8080
      protocol: TCP
      targetPort: 8080
  selector:
    app: app-name
  type: ClusterIP
```
</details>


<p>
<details>
<summary>external-secret-application-json.yml</summary>

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-name-external-secret-application-json
  namespace: app_namespace
spec:
  refreshInterval: "1h"
  secretStoreRef:
    name: app-name-secret-store
    kind: SecretStore
  target:
    name: app-name-secret-spring-application-json
  data:
    - secretKey: SPRING_APPLICATION_JSON
      remoteRef:
        key: path/to/vault/dev
    - secretKey: JAVA_VM_ARGS
      remoteRef:
        key: path/to/vault/dev
        property: JAVA_VM_ARGS

```
</details>


<p>
<details>
<summary>ingress.yml</summary>

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-name-ingress
  namespace: app_namespace
  annotations:
    #kubernetes
    kubernetes.io/ingress.class: "private"
    # cert-manager
    cert-manager.io/issuer: app-name-issuer
    cert-manager.io/email-sans: author_email
    # to allow TLS 1.2 (1.3 is default)
    # nginx.ingress.kubernetes.io/ssl-protocols: "TLSv1.2 TLSv1.3"
    # appgw.ingress.kubernetes.io/ssl-policy-name: "AppGwSslPolicy20170401S"
spec:
  ingressClassName: private
  tls:
    - hosts:
      - local.dns.app.url
      secretName: mysecret-cert
  rules:
    - host: local.dns.app.url
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: app-name-svc
                port:
                  number: 8080
          - path: /v3
            pathType: Prefix
            backend:
              service:
                name: app-name-svc
                port:
                  number: 8080

```
</details>


<p>
<details>
<summary>secret-store.yml</summary>

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: app-name-secret-store
  namespace: app_namespace
spec:
  provider:
    vault:
      server: "https://vault.server.com" # The URL of the Vault server.
      path: "path/to/nonprod" # The mount point of the NON-PROD KV
      version: "v2" # The version of the KV engine (do not change this configuration).
      caBundle: xxxxxxxxxx==
      auth:
        kubernetes:
          role: "app-np-kubernetes" # The role to use to authenticate to Vault on NON-PROD KV
          mountPath: "kubernetes/name_of_k8s_cluster" # The mount path of the Kubernetes auth method
          serviceAccountRef:
            name: "default" # The default service account provided by Kubernetes.
```
</details>

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
