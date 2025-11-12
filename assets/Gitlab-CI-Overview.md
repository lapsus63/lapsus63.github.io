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
  
