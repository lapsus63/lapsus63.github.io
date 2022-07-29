# Cucumber

### Documentation

- https://cucumber.io/ ; http://docs.cucumber.io/guides/
- installation: npm install --save-dev cucumber
- tutorial: http://docs.cucumber.io/guides/10-minute-tutorial/
- quick install : npm install cucumber --save-dev
- human readable functions ("Is it Friday Yet?"), Ressemble à RobotFramework - Given/When/Then statements
- Selenium WebDriver
- Intégré à Jenkins (Cucumber report plugin)

### Using with maven and 

Portions of `pom.xml` file:

```xml
<dependency>
    <groupId>io.cucumber</groupId>
    <artifactId>cucumber-java</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>io.cucumber</groupId>
    <artifactId>cucumber-junit-platform-engine</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.platform</groupId>
    <artifactId>junit-platform-suite</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.junit.jupiter</groupId>
    <artifactId>junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <version>3.0.0-M5</version>
    <configuration>
        <includes>
            <include>**/RunAllSuiteTest.class</include>
        </includes>
    </configuration>
</plugin>
```

The maven test execution:

```bash
mvn clean test
# check generated results in target/SystemTestReports
```

A feature file `src/test/resources/com/company/app/featurename/test-file.feature`

```yaml
Feature: Description of the feature line 1
  line 2, etc.

  Background:
    Given Initialization task
    And Another Initialization Task Repeated for each scenario

 ##############################################################################

  Scenario: Nominal case
    # A comment
    Given I init the DB using "path/to/myscript.sql"
    When I read the application log
    Then I should find "this text"
    Then The application should be running
  
  @ExcludeFromCI
  Scenario: Manual test
    # Run only from my IDE, not from RunAllTests
```

A definition file `src/test/java/com/company/app/definitions/category/DataDef.java`

```java
    @Given("I init the DB using {string}")
    public void init_db(String pathToSql) {
      // Do something
    }
    
    @When("I read the application log")
    public static void read_log() {
      // Do something
    }
```

The entrypoint of the cucumber application `RunAllSuiteTest.java`

```java
@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("com/company/app/")
@ExcludeTags("ExcludeFromCI")
```
