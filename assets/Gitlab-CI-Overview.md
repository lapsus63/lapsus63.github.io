# Gitlab CI

### Prevent double pipelines on push + open merge requests

```yaml
# prevent double pipelines, but allow both branch and MR pipelines separately
  rules:
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never
```

### Gitlab CI configuration project files


<p>
<details>
<summary>.gitlab/merge_request_templates/default.md</summary>

```md
### Things to check for approval
- [ ] Pipeline
- [ ] Code review
- [ ] Documentation
- [ ] Code quality Sonar
- [ ] Changelog + commit message
```
	
</details>


### Gitlab full CI/CD pipeline


<p>
<details>
<summary>.gitlab-ci.yml</summary>


```yaml

include:
  - project: path/to/commons_project/subfolder
    file: filename.yml
    ref: 1.2.0

variables:
  GIT_SUBMODULE_STRATEGY: recursive
  VAULT_SERVER_URL: https://vault.server.com
  SONAR_TAGS:
    value: false
    description: "Tag sonar project with project tags"
  GIT_LEAKS_FULL_SCAN:
    value: false
    description: "Scan all files in the git history"
  SKIP_TESTS:
    value: false
    description: "Manually skip testing"

stages:
  - prepare_ci
  - build
  - test
  - publish
  - deploy

# https://docs.gitlab.com/ci/yaml/workflow/#switch-between-branch-pipelines-and-merge-request-pipelines
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "web"
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never
    - if: $CI_COMMIT_BRANCH
    - if: $CI_COMMIT_TAG

#######################################################################################################################
##                                              BUILD AND TEST STEPS                                                 ##
#######################################################################################################################

load_cicd_variables:
  stage: prepare_ci
  image: docker.image
  variables:
    ARTIFACTORY_USER: $GITLAB_USER_LOGIN
    VAULT_AUTH_PATH: gitlab
    VAULT_AUTH_ROLE: vaul-role-np
  id_tokens:
    VAULT_ID_TOKEN:
      aud: $VAULT_SERVER_URL
  secrets:
    ARTIFACTORY_TOKEN:
      vault:
        engine:
          name: generic
          path: artifactory
        path: user_token/$GITLAB_USER_LOGIN
        field: access_token
      file: false
    AGE_PRIVATE_KEY:
      vault: path/to/vault/AGE_PRIVATE_KEY@apps/app/kv/nonprod
      file: false
    ARTIFACTORY_URL:
    DOCKER_PROD_REGISTRY:
    DOCKER_TEAM_SNAPSHOT_REGISTRY:
    DOCKER_TEAM_RELEASE_REGISTRY:
    DOCKER_REGISTRY:
    SONARQUBE_TOKEN:
    SONARQUBE_URL:
  script:
    - echo "AGE_PRIVATE_KEY=$AGE_PRIVATE_KEY" > vault.env
    - echo "ARTIFACTORY_TOKEN=$ARTIFACTORY_TOKEN" >> vault.env
    - ...
  rules:
    - if: '$GITLAB_USER_LOGIN != "renovate"'
      when: always
  artifacts:
    reports:
      dotenv: vault.env
    expire_in: 30 mins

⛏ build-maven:
  stage: build
  extends: .maven-build
  script:
    # On a tag pipeline, update the version in the pom.xml with the tag name without the v prefix (v1.2.3 -> 1.2.3):
    - if [ -n "$CI_COMMIT_TAG" ] && [[ "$CI_COMMIT_TAG" == v* ]]; then mvn $MAVEN_CLI_OPTS versions:set -DnewVersion="${CI_COMMIT_TAG#v}" -DgenerateBackupPoms=false; fi
    - mvn $MAVEN_CLI_OPTS -Dskip.it=true -Dskip.ut=true clean package
  artifacts:
    expire_in: 4h
    paths:
      - $CI_PROJECT_DIR/target

☔ test-maven-junit-sonar:
  stage: build
  needs:
    - ⛏ build-maven
  extends: .maven-test
  script:
    - mvn $MAVEN_CLI_OPTS -Duser.timezone=GMT -Duser.country=US -Duser.language=en org.jacoco:jacoco-maven-plugin:prepare-agent verify org.jacoco:jacoco-maven-plugin:report
    - mvn $MAVEN_CLI_OPTS sonar:sonar $SONAR_OPTS -Dsonar.token=$SONARQUBE_TOKEN -Dsonar.verbose=true -Dsonar.qualitygate.wait="true"
  rules:
    - if: $SKIP_TESTS == "true"
      when: never
    - if: $CI_COMMIT_TAG
      when: never
    - when: on_success
  artifacts:
    when: always
    expire_in: 4h
    paths:
      - $CI_PROJECT_DIR/target

☔ test-maven-xray:
  stage: build
  image: docker.image.jfrog
  needs:
    - job: load_cicd_variables
      optional: true
    - ⛏ build-maven
  variables:
    JF_WATCHES: WATCH_LIST_NAME
    JAR_FILE: target/$CI_PROJECT_NAME.jar
    REPORT_FILE: xray_report.json
  script:
    - jf c add artifactory --artifactory-url=$ARTIFACTORY_URL --xray-url=$ARTIFACTORY_URL/xray --user=$ARTIFACTORY_USER --password=$ARTIFACTORY_TOKEN -interactive=false
    - jf scan $JAR_FILE --watches=$JF_WATCHES --format=json | tee $REPORT_FILE
  artifacts:
    when: always
    expire_in: 4h
    paths:
      - $CI_PROJECT_DIR/$REPORT_FILE
  rules:
    - if: '$GITLAB_USER_LOGIN == "renovate"'
      when: never
    - if: $SKIP_TESTS == "true"
      when: never
    - if: $CI_COMMIT_TAG
      when: never
    - when: on_success

☔ test-git-leaks:
  # default toml configuration: https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml
  stage: build
  image:
    name: image.docker.gitleaks
    entrypoint: [""]
  variables:
    REPORT_FILE: gl-secret-detection-report.json
  script:
    # "--exit-code 0" to prevent CI from failing when secrets are found (or use gitlab allow_failures: true)
    # can current directory only
    - gitleaks dir . -v -f json -r $REPORT_FILE
  artifacts:
    when: always
    expire_in: 4h
    paths:
      - $CI_PROJECT_DIR/$REPORT_FILE
  rules:
    - if: $SKIP_TESTS == "true"
      when: never
    - if: $CI_COMMIT_TAG
      when: never
    - when: on_success

☔ test-git-leaks-full-scan:
  # default toml configuration: https://github.com/gitleaks/gitleaks/blob/master/config/gitleaks.toml
  stage: build
  image:
    name: docker.image.gitleaks
    entrypoint: [""]
  variables:
    REPORT_FILE: gl-secret-detection-report.json
  script:
    # "--exit-code 0" to prevent CI from failing when secrets are found (or use gitlab allow_failures: true)
    # scan git repository:
    - gitleaks git . --platform gitlab -v -f json -r $REPORT_FILE
  artifacts:
    when: always
    expire_in: 4h
    paths:
      - $CI_PROJECT_DIR/$REPORT_FILE
  rules:
    - if: $GIT_LEAKS_FULL_SCAN == "true"
      when: on_success
    - when: never

🔬 sonar-tags:
  stage: test
  extends: .set-sonarqube-project-tags
  rules:
    - if: $SONAR_TAGS == "true"
      when: on_success
    - when: never

📦 generate-deploy-pipeline:
  stage: publish
  image: docker.image.url
  script:
    - sh generate-deploy-pipeline.sh .generated-deploy-pipeline.yml
    - cat .generated-deploy-pipeline.yml
  rules:
    - if: '$GITLAB_USER_LOGIN == "renovate"'
      when: never
    - if: '$CI_PIPELINE_SOURCE == "web" || $CI_PIPELINE_SOURCE == "push" || $CI_PIPELINE_SOURCE == "merge_request_event" || $CI_PIPELINE_SOURCE == "trigger"'
      when: on_success
  artifacts:
    paths:
      - .generated-deploy-pipeline.yml

#######################################################################################################################
##                                              DOCKER STEPS                                                         ##
#######################################################################################################################


.prepare-registry-auth: &prepare-registry-auth |
  echo "{\"auths\":{\"DOCKER_TEAM_SNAPSHOT_REGISTRY\":{\"username\":\"$ARTIFACTORY_USER\",\"password\":\"$ARTIFACTORY_TOKEN\"}}}" > /kaniko/.docker/config.json

⛏ build-docker:
  stage: build
  needs:
    - job: load_cicd_variables
      optional: true
    - ⛏ build-maven
  image: docker.image.kaniko
  variables:
    DOCKERFILE_PATH: .k8s/Dockerfile
    KANIKO_IMAGE_TARGET: "run"
    IMAGE_TAR_FILE: $CI_PROJECT_NAME-image.tar
  script:
    - *prepare-registry-auth
    - /kaniko/executor
      --context $CI_PROJECT_DIR
      --target $KANIKO_IMAGE_TARGET
      --skip-unused-stages
      --dockerfile $DOCKERFILE_PATH
      --snapshot-mode redo
      --use-new-run
      --no-push
      --tarPath $IMAGE_TAR_FILE
  rules:
    - if: '$GITLAB_USER_LOGIN == "renovate"'
      when: never
    - when: on_success
  artifacts:
    when: on_success
    expire_in: 4h
    paths:
      - $CI_PROJECT_DIR/$IMAGE_TAR_FILE

☔ test-docker-xray:
  stage: build
  needs:
    - job: load_cicd_variables
      optional: true
    - ⛏ build-docker
  image: docker.image.jfrog
  variables:
    IMAGE_TAR_FILE: $CI_PROJECT_NAME-image.tar
    JF_WATCHES: WATCH_LIST_NAME
    REPORT_FILE: xray_report.json
  script:
    - jf c add artifactory --artifactory-url=$ARTIFACTORY_URL --xray-url=$ARTIFACTORY_URL/xray --user=$ARTIFACTORY_USER --password=$ARTIFACTORY_TOKEN -interactive=false
    - jf scan $IMAGE_TAR_FILE --watches=$JF_WATCHES --format=json | tee $REPORT_FILE
  allow_failure: true
  rules:
    - if: '$GITLAB_USER_LOGIN == "renovate"'
      when: never
    - if: $SKIP_TESTS == "true"
      when: never
    - if: $CI_COMMIT_TAG
      when: never
    - when: on_success
  artifacts:
    when: always
    expire_in: 4h
    paths:
      - $CI_PROJECT_DIR/$IMAGE_TAR_FILE
      - $CI_PROJECT_DIR/$REPORT_FILE

🐳 push-docker-snapshot:
  image:
    name: image.docker.crane
    entrypoint: [""]
  stage: publish
  variables:
    IMAGE_TAR_FILE: $CI_PROJECT_NAME-image.tar
    IMAGE_DESTINATION: $DOCKER_TEAM_SNAPSHOT_REGISTRY/app_name/$CI_PROJECT_NAME:$CI_COMMIT_SHORT_SHA
    VAULT_AUTH_PATH: gitlab
  id_tokens:
    VAULT_ID_TOKEN:
      aud: $VAULT_SERVER_URL
  secrets:
    ARTIFACTORY_TOKEN:
      vault:
        engine:
          name: generic
          path: artifactory
        path: user_token/$GITLAB_USER_LOGIN
        field: access_token
      file: false
  script:
    - crane auth login -u $ARTIFACTORY_USER -p $ARTIFACTORY_TOKEN $DOCKER_TEAM_SNAPSHOT_REGISTRY
    - crane push $IMAGE_TAR_FILE $IMAGE_DESTINATION
  rules:
    - if: '$GITLAB_USER_LOGIN == "renovate"'
      when: never
    - if: '$CI_COMMIT_TAG && $SKIP_TESTS == "false"'
      when: on_success
    - when: manual

🐳 push-docker-release:
  image:
    name: image.docker.crane
    entrypoint: [""]
  stage: publish
  variables:
    IMAGE_DESTINATION: $DOCKER_TEAM_RELEASE_REGISTRY/my_app/$CI_PROJECT_NAME:$CI_COMMIT_TAG
    IMAGE_TAR_FILE: $CI_PROJECT_NAME-image.tar
  script:
    - crane auth login -u $ARTIFACTORY_USER -p $ARTIFACTORY_TOKEN $DOCKER_TEAM_RELEASE_REGISTRY
    - crane push $IMAGE_TAR_FILE $IMAGE_DESTINATION
  rules:
    - if: '$CI_COMMIT_TAG && $SKIP_TESTS == "false"'
      when: on_success


#######################################################################################################################
##                                              PROMOTE STEPS                                                        ##
#######################################################################################################################

👨‍🎓 promote:
  stage: publish
  image:
    name: image.docker.promote-artifact
  needs:
    - job: load_cicd_variables
      optional: true
    - 🐳 push-docker-release
  variables:
    PROMOTE_URL: "https://artifactory.url/api/plugins/execute/promote"
    PROMOTE_TOKEN: $ARTIFACTORY_TOKEN
    PROMOTE_FROM_REPO: "my_app-docker-release"
    PROMOTE_IMAGES: "my_app/$CI_PROJECT_NAME:$CI_COMMIT_TAG"
    PROMOTE_WATCH: "WATCH_LIST_NAME"
    PROMOTE_FORCE: false
    PROMOTE_DRY_RUN: false
  script:
    - /promote.sh
  rules:
    - if: $CI_COMMIT_TAG


#######################################################################################################################
##                                              RELEASE NOTES                                                        ##
#######################################################################################################################

📓 generate-note:
  stage: publish
  image: docker.image.url
  variables:
      CI_API_V4_URL: "gitlab.ci.api.url"
  script:
    - |
      VERSION=$(echo $CI_COMMIT_REF_NAME | cut -d 'v' -f2)
      echo VERSION=$VERSION
      curl -H "PRIVATE-TOKEN: $CICD_API_PROJECT_TOKEN" "$CI_API_V4_URL/user"
      # sed: remplacement des liens vers les commits par les liens vers les tickets JIRA
      # la version doit être au format vX.Y.Z-xyz (ex: v1.2.3, v1.2.3-SNAPSHOT, v1.2.3-c01, ...) cf. https://semver.org/
      curl -H "PRIVATE-TOKEN: $CICD_API_PROJECT_TOKEN" "$CI_API_V4_URL/projects/$CI_PROJECT_ID/repository/changelog?version=$VERSION" | sed -E 's/\[(XXX-[0-9]{3,})([^]]+)[^)]+\)/[\1\2](https:\/\/jira.server.url\/jra\/browse\/\1)/g' | jq -r .notes | tee release_notes.md
  rules:
    - if: $SKIP_TESTS == "true"
      when: never
    - when: on_success
  artifacts:
    paths:
      - release_notes.md

📓 publish-release-note:
  stage: deploy
  image: docker.image.release-cli-gitlab
  script:
    - echo "Creating release note for $CI_COMMIT_REF_NAME"
  release:
    name: '$CI_COMMIT_REF_NAME'
    description: release_notes.md
    tag_name: '$CI_COMMIT_REF_NAME'
    ref: '$CI_COMMIT_SHA'
  rules:
    - if: $SKIP_TESTS == "true"
      when: never
    - if: $CI_COMMIT_TAG

#######################################################################################################################
##                                              DEPLOY STEPS                                                         ##
#######################################################################################################################

deploy-pipeline:
  stage: deploy
  variables:
    PARENT_PIPELINE_ID: ${CI_PIPELINE_ID}
    SKIP_TESTS: ${SKIP_TESTS}
    DOCKER_REGISTRY: ${DOCKER_REGISTRY}
  rules:
    - if: '$GITLAB_USER_LOGIN == "renovate"'
      when: never
    - when: on_success
  trigger:
    include:
      - artifact: .generated-deploy-pipeline.yml
        job: 📦 generate-deploy-pipeline
    strategy: depend

```
</details>


<p>
<details>
<summary>generate-deploy-pipeline.sh</summary>
```sh
#!/bin/sh -xe

OUTPUT_YML=$1

# Pipeline header
###############################################################################

cat << EOF1 > ${OUTPUT_YML}

# This file is auto-generated by generate-deploy-pipeline.sh

include:
  - project: path/to/commons_project/subfolder
    file: commons_tools.yml
    ref: 1.0.0

default:
  tags:
    - runner-tags

stages:
  - 💈 prepare
  - 🚀 deploy
  - ✅ check

.validate-readyness-liveness:
  image: image.docker.kubectl
  variables:
    AGE_PRIVATE_KEY: \$AGE_PRIVATE_KEY
    K8S_OVERLAY_PATH: .k8s/overlays
    KUBE_CONFIG_PATH: kubectl_config
  script:
    - cd \$K8S_OVERLAY_PATH/\$ENVIRONMENT
    - export SOPS_AGE_KEY=\$AGE_PRIVATE_KEY
    - sops -d -i \$KUBE_CONFIG_PATH
    - kubectl --kubeconfig \$KUBE_CONFIG_PATH get pods --no-headers | grep "$CI_PROJECT_NAME" | grep -v "Terminating" | awk '{print \$1}' | xargs -I {} kubectl --kubeconfig \$KUBE_CONFIG_PATH wait pod {} --for=condition=Ready --timeout=300s

EOF1

# Pipeline body
###############################################################################

# env_list contains always "dev" and "qua", and also "indus" and "prod" only when $CI_COMMIT_TAG is set
if [ -z "$CI_COMMIT_TAG" ]; then
  env_list="dev qua"
else
  env_list="dev qua indus prod"
fi

for ENV in $env_list; do
echo "Generating pipeline for $ENV"

IMAGE_TO_DEPLOY=\${DOCKER_TEAM_SNAPSHOT_REGISTRY}/app_name/\${CI_PROJECT_NAME}:\${CI_COMMIT_SHORT_SHA}
DEFAULT_WHEN_MODE=manual

if [ "dev" = "$ENV" ]; then
  DEFAULT_WHEN_MODE=on_success
fi
if [ "qua" = "$ENV" ]; then
  DEFAULT_WHEN_MODE=on_success
fi
if [ "indus" = "$ENV" ]; then
  IMAGE_TO_DEPLOY=\${DOCKER_PROD_REGISTRY}/app_name/\${CI_PROJECT_NAME}:\${CI_COMMIT_TAG}
fi
if [ "prod" = "$ENV" ]; then
  IMAGE_TO_DEPLOY=\${DOCKER_PROD_REGISTRY}/app_name/\${CI_PROJECT_NAME}:\${CI_COMMIT_TAG}
fi

cat << EOF2 >> ${OUTPUT_YML}
💈 prepare-${ENV}:
   stage: 💈 prepare
   image: image.dosker.url
   needs:
     - pipeline: \${PARENT_PIPELINE_ID}
       job: load_cicd_variables
   id_tokens:
     VAULT_ID_TOKEN:
       aud: \${VAULT_SERVER_URL}
   secrets:
     ARTIFACTORY_TOKEN:
       vault:
         engine:
           name: generic
           path: artifactory
         path: user_token/\${GITLAB_USER_LOGIN}
         field: access_token
       file: false
   script:
     - echo "Artifactory token refreshed!"
     - echo "ARTIFACTORY_TOKEN=$ARTIFACTORY_TOKEN" > vault.env
   rules:
     - if: \$GITLAB_USER_LOGIN == "renovate"
       when: never
   artifacts:
     reports:
       dotenv: vault.env
     expire_in: 30 mins

🚀 deploy-${ENV}:
   stage: 🚀 deploy
   needs:
     - pipeline: \${PARENT_PIPELINE_ID}
       job: load_cicd_variables
   extends: .deploy-k8s
   variables:
     ENVIRONMENT: ${ENV}
     IMAGE_TO_DEPLOY: ${IMAGE_TO_DEPLOY}
   rules:
     - if: \$GITLAB_USER_LOGIN == "renovate"
       when: never
     - if: \$CI_COMMIT_TAG && ("indus" == "$ENV" || "prod" == "$ENV")
       when: manual
     - if: \$SKIP_TESTS == "true" && ("indus" == "$ENV" || "prod" == "$ENV")
       when: never
     - when: ${DEFAULT_WHEN_MODE}

💫 validate-${ENV}:
   stage: ✅ check
   needs:
     - 🚀 deploy-${ENV}
     - pipeline: \${PARENT_PIPELINE_ID}
       job: load_cicd_variables
   extends: .validate-readyness-liveness
   variables:
     ENVIRONMENT: ${ENV}
   rules:
     - if: \$SKIP_TESTS == "false" && \$CI_COMMIT_TAG && ("indus" == "$ENV" || "prod" == "$ENV")
     - if: \$SKIP_TESTS == "true" && ("indus" == "$ENV" || "prod" == "$ENV")
       when: never
     - when: on_success

EOF2
done

```
</details>


### Gitlab CI files for multi-module project with maven and Spring

<p>
<details>
<summary>submodule ci.git/.gitlab-ci.yml</summary>

```yaml
variables:
  CI_DEPLOY_SPRING_MODE:
    value: "none"
    description: "One of these values: none, snapshot, build, minor, major"
  RUN_TESTS:
    value: "true"
    description: "Run unit tests and sonar analysis"

# Cache the Maven repository so that each job does not have to download it.
cache:
  key: maven-$CI_COMMIT_REF_SLUG
  paths:
    - .m2
  policy: pull-push

#######################################
# Run tests and code coverage         #
#######################################
test_sonar_auto:
  image: <docker.url.for.debian.with.jdk>
  stage: test
  script:
    - echo CI_COMMIT_TITLE=$CI_COMMIT_TITLE CI_COMMIT_MESSAGE=$CI_COMMIT_MESSAGE
    - '[ "true"  == "${RUN_TESTS}" ] && mvn ${MAVEN_CLI_OPTS} ${SONAR_OPTS} clean verify sonar:sonar'
    - '[ "false" == "${RUN_TESTS}" ] && mvn ${MAVEN_CLI_OPTS} ${SONAR_OPTS} clean verify -DskipTests -DskipTests=true'
    - awk -F"," '{ lines += $8 + $9; covered += $9 } END { print covered, "/", lines, "lines covered"; print 100*covered/lines, "% covered" }' target/site/jacoco/jacoco.csv || echo "0.0 % covered"
  variables:
    MAVEN_OPTS: "-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
    MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end"
    SONAR_USER_HOME: .m2/sonar
    SONAR_OPTS: "-Dsonar.qualitygate.wait=true -Dsonar.gitlab.quality_gate_fail_mode=WARN -Dsonar.branch.name=$CI_COMMIT_REF_NAME -Dsonar.host.url=<sonar.url> -Dsonar.projectKey=$SONAR_PROJECT_KEY -Dsonar.login=<sonar.api.key>"
  coverage: '/\d+.*\d+ \% covered/'
  allow_failure: false
  interruptible: true
  only:
    refs:
      - web
      - pushes
  artifacts:
    # share artifacts even on stage error
    when: always
    expire_in: 1 week
    paths:
      - target/
    reports:
      junit:
        - target/surefire-reports/TEST-*.xml
        - target/failsafe-reports/TEST-*.xml
  tags:
    - <tags-for-runners>

release_snapshot:
  image: <docker.url.for.debian.with.jdk>
  stage: deploy
  dependencies: [test_sonar_auto]
  allow_failure: false
  interruptible: true
  before_script:
    - git submodule sync
    - git submodule update --init --remote --force
  script:
    - mvn ${MAVEN_CLI_OPTS} deploy -Dfile.encoding=UTF-8 -Dmaven.main.skip -DskipTests -DskipTests=true
  variables:
    MAVEN_OPTS: "-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
    MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end"
  only:
    variables:
      - $CI_DEPLOY_SPRING_MODE == "snapshot"
    refs:
      - web
      - pushes
  artifacts:
    # share artifacts for pages
    when: always
    expire_in: 1 week
    paths:
      - target/
  tags:
    - <tags-for-runners>

.release_x_artifactory:
  image: <docker.url.for.debian.with.jdk>
  stage: deploy
  dependencies: [test_sonar_auto]
  allow_failure: false
  interruptible: true
  before_script:
    - git submodule sync
    - git submodule update --init --remote --force
  script:
    - chmod a+x ${CI_FILES_DIR}/release.sh && ${CI_FILES_DIR}/release.sh
  variables:
    MAVEN_OPTS: "-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
    MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end"
  only:
    refs:
      - branches
    variables:
      - $CI_COMMIT_REF_PROTECTED == "true"
  artifacts:
    # share artifacts for pages
    when: always
    expire_in: 1 week
    paths:
      # release.*, pom.xml.* and ci used for release:prepare in the next stage
      - release.*
      - pom.xml.*
      - target/
      - ci/
  tags:
    - <tags-for-runners>

release_major:
  extends: .release_x_artifactory
  only:
    variables:
      - $CI_DEPLOY_SPRING_MODE == "major"

release_minor:
  extends: .release_x_artifactory
  only:
    variables:
      - $CI_DEPLOY_SPRING_MODE == "minor"

release_build:
  extends: .release_x_artifactory
  only:
    variables:
      - $CI_DEPLOY_SPRING_MODE == "build"

store_release:
  # Step in a separate stage to be able to retry pub to artifactory in case of comm failure without making a new tag
  image: <docker.url.for.debian.with.jdk>
  stage: store_deploy
  allow_failure: false
  interruptible: true
  script:
    # perform release:
    # checkout the tag in target/checkout
    # run goals deploy site-deploy from target/checkout
    - mvn ${MAVEN_CLI_OPTS} -s ${CI_FILES_DIR}/mvn-settings.xml -Darguments="-DskipTests -DrepositoryId=central" release:perform
  variables:
    MAVEN_OPTS: "-Dhttps.protocols=TLSv1.2 -Dmaven.repo.local=.m2/repository -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"
    MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end"
  only:
    refs:
      - branches
    variables:
      - $CI_COMMIT_REF_PROTECTED == "true"
  except:
    variables:
      - $CI_DEPLOY_SPRING_MODE  == "none"
  tags:
    - <tags-for-runners>
```

</details>
</p>

<p>
<details>
<summary>module project.git/.gitlab-ci.yml with submodule ci</summary>

```yaml
variables:
  SONAR_PROJECT_KEY: <the.sonar.project.key>
  CI_FILES_DIR: ${CI_PROJECT_DIR}/ci

stages:
  - test
  - deploy
  - store_deploy
  - changelog_pages

include:
  - project: 'relative/path/to/ci'
    ref: <the.branch>
    file:
      - '.gitlab-ci.yml'

pages:
  stage: changelog_pages
  script:
    - rm -rf public
    - mkdir public
    - cp target/classes/CHANGELOG.md doc/*.html doc/*.css public/
  rules:
    - if: $CI_DEPLOY_SPRING_MODE == "minor"
    - if: $CI_DEPLOY_SPRING_MODE == "major"
    - if: $CI_DEPLOY_SPRING_MODE == "build"
    - if: $CI_DEPLOY_SPRING_MODE == "snapshot"
  artifacts:
    paths:
      - public
  tags:
    - <tags-for-runners>
```

</details>
</p>

<p>
<details>
<summary>The maven_release.sh file</summary>

```bash
#!/bin/bash -e

# defaults to "mvn-" if TAG_PREFIX not provided
TAG_PREFIX=${SONAR_PROJECT_KEY:-mvn-}

# Initialize git environment to allow remote access
#######################################
git config user.email "gitlab-runner@<mycompany>.com"
git config user.name "Gitlab Runner"

# Determine current and new version for pom.xml file
#######################################

case $CI_DEPLOY_SPRING_MODE in
  major)
    MVN_TAG_VERSION=$( mvn -q -Dexec.executable=echo \
      -Dexec.args='${parsedVersion.nextMajorVersion}.0.0' \
      --non-recursive build-helper:parse-version help:effective-pom exec:exec
    )
    MVN_DEV_VERSION=$( mvn -q -Dexec.executable=echo \
      -Dexec.args='${parsedVersion.nextMajorVersion}.0.1-SNAPSHOT' \
      --non-recursive build-helper:parse-version help:effective-pom exec:exec
    )
    ;;
  minor)
    MVN_TAG_VERSION=$( mvn -q -Dexec.executable=echo \
      -Dexec.args='${parsedVersion.majorVersion}.${parsedVersion.nextMinorVersion}.0' \
      --non-recursive build-helper:parse-version help:effective-pom exec:exec
    )
    MVN_DEV_VERSION=$( mvn -q -Dexec.executable=echo \
      -Dexec.args='${parsedVersion.majorVersion}.${parsedVersion.nextMinorVersion}.1-SNAPSHOT' \
      --non-recursive build-helper:parse-version help:effective-pom exec:exec
    )
    ;;
  build)
    MVN_TAG_VERSION=$( mvn -q -Dexec.executable=echo \
      -Dexec.args='${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.incrementalVersion}' \
      --non-recursive build-helper:parse-version help:effective-pom exec:exec
    )
    MVN_DEV_VERSION=$( mvn -q -Dexec.executable=echo \
      -Dexec.args='${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion}-SNAPSHOT' \
      --non-recursive build-helper:parse-version help:effective-pom exec:exec
    )
    ;;
esac

echo "CI_DEPLOY_SPRING_MODE:${CI_DEPLOY_SPRING_MODE} - MVN_TAG_VERSION:${MVN_TAG_VERSION} - MVN_DEV_VERSION:${MVN_DEV_VERSION}"


# Prepare and perform release, tag version, upload to artifactory
#######################################

# delete all local tags (cache cleanup)
git tag -d $(git tag -l)

git checkout -f $CI_COMMIT_BRANCH
git fetch --all
git reset --hard origin/$CI_COMMIT_BRANCH
git status

# Update CHANGELOG.md version (replace variables with target tag version)
CHLOG_TIMESTAMP=$(date -u '+%Y-%m-%d %H:%M %Z')
CHLOG_PATTERN="## @project.version@ - @timestamp@"
CHLOG_REPLBY="## ${MVN_TAG_VERSION} - ${CHLOG_TIMESTAMP}"
sed -i "s/${CHLOG_PATTERN}/${CHLOG_REPLBY}/" CHANGELOG.md

git add CHANGELOG.md
git commit -m "[skip ci] Committing CHANGELOG.md from latest release"
echo "[INFO] Committing CHANGELOG.md from latest release"
git push "https://gitlab-ci:${CI_GIT_TOKEN}@${CI_REPOSITORY_URL#*@}"

# prepare release
# git commit push pom.xml (0.0.1-SNAPSHOT -> 0.0.1)
# git tag push mvn-x.x.x
# git commit push pom.xml ( 0.0.1 -> 0.0.2-SNAPSHOT)
echo "[INFO] Tagging version ${TAG_PREFIX}-${MVN_TAG_VERSION}:"
mvn ${MAVEN_CLI_OPTS} -s ${CI_FILES_DIR}/mvn-settings.xml -Darguments=-DskipTests -Dfile.encoding=UTF-8 release:clean release:prepare -DdryRun=false -Dresume=false -DscmCommentPrefix="[skip ci]" -Dtag=${TAG_PREFIX}-${MVN_TAG_VERSION} -DreleaseVersion=${MVN_TAG_VERSION} -DdevelopmentVersion=${MVN_DEV_VERSION}

# Prepare the new version of CHANGELOG.md for the next release
CHLOG_PATTERN="## "
CHLOG_REPLBY="## @project.version@ - @timestamp@\n### Added\n### Changed\n\n## "
sed -i "0,/${CHLOG_PATTERN}/{s/${CHLOG_PATTERN}/${CHLOG_REPLBY}/}" CHANGELOG.md

git add CHANGELOG.md
git commit -m "[skip ci] Committing CHANGELOG.md for next release"
echo "[INFO] Committing CHANGELOG.md for next release"
git push "https://gitlab-ci:${CI_GIT_TOKEN}@${CI_REPOSITORY_URL#*@}"

```

</details>
</p>
<p>
<details>
<summary>The maven-settings.xml file</summary>

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

    <servers>
        <server>
            <id><gitlab.url></id>
            <username>oauth2</username>
            <password>${env.CI_GIT_TOKEN}</password>
        </server>
        <server>
            <id>central</id>
            <username>artifactory.username</username>
            <password>${env.CI_JFROG_TOKEN}</password>
        </server>
        <server>
            <id>snaphots</id>
            <username>artifactory.username</username>
            <password>${env.CI_JFROG_TOKEN}</password>
        </server>
    </servers>
  
</settings>

```

</details>
</p>
  
  
</details>
</p>
<p>
<details>
<summary>The main pom.xml parts</summary>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">

	<version>0.0.7-SNAPSHOT</version>

	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		<sonar.java.binaries>${project.build.directory}/classes</sonar.java.binaries>
		<!-- maven release options -->
		<maven.javadoc.skip>true</maven.javadoc.skip>
		<maven.source.skip>true</maven.source.skip>
		<maven.javadoc.failOnError>false</maven.javadoc.failOnError>
		<!-- maven timestamping for version changelog -->
		<timestamp>${maven.build.timestamp}</timestamp>
		<maven.build.timestamp.format>yyyy-MM-dd HH:mm Z</maven.build.timestamp.format>
	</properties>

	<scm>
		<!-- credentials read from maven settings file -->
		<developerConnection>scm:git:https://url.to.project.git</developerConnection>
		<url>https://url.to.project</url>
  </scm>

	<distributionManagement>
		<repository>
			<id>central</id>
			<name>the.name.releases</name>
			<url>https://path/to/artifactory/libs-release</url>
		</repository>
		<snapshotRepository>
			<id>snapshots</id>
			<name>the.name.snapshots</name>
			<url>https://path/to/artifactory/libs-snapshots</url>
		</snapshotRepository>
	</distributionManagement>

	<dependencies>
	</dependencies>

	<build>
		<resources>
			<resource>
				<directory>src/main/resources</directory>
				<filtering>true</filtering>
			</resource>
			<resource>
				<directory>.</directory>
				<includes>
					<include>CHANGELOG.md</include>
				</includes>
				<filtering>true</filtering>
			</resource>
		</resources>
		<plugins>
			<!-- Version incrementing management (release_artifactory.sh) -->
			<!-- https://www.mojohaus.org/build-helper-maven-plugin/parse-version-mojo.html -->
			<plugin>
				<groupId>org.codehaus.mojo</groupId>
				<artifactId>build-helper-maven-plugin</artifactId>
				<version>3.2.0</version>
				<executions>
					<execution>
						<id>parse-version</id>
						<goals>
							<goal>parse-version</goal>
						</goals>
					</execution>
				</executions>
			</plugin>

			<!--  -->
			<plugin>
				<groupId>org.codehaus.mojo</groupId>
				<artifactId>versions-maven-plugin</artifactId>
				<version>2.8.1</version>
			</plugin>

			<!-- Release management -->
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-release-plugin</artifactId>
				<version>2.5.3</version>
			</plugin>

		</plugins>
	</build>

</project>
```

</details>
</p>
  
