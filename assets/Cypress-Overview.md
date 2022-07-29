# Cypress 

### Overview

See <a href="https://docs.cypress.io/guides/overview/why-cypress.html#In-a-nutshell">Overview</a>. 
Cypress is a next generation front end testing tool built for the modern web, independant from Selenium (<a href="https://docs.cypress.io/guides/overview/key-differences.html">differences</a>)
- End-to-end tests, Integration tests, unit tests
- Free, open source, locally installed.
- Compatible with <a href="https://docs.cypress.io/guides/guides/continuous-integration.html#What-is-supported">Jenkins</a>, but no Jenkins post-build plugin found for cypress reports (contrary to cucumber).
- See <a hreef="https://docs.cypress.io/guides/overview/why-cypress.html#Features">features</a>.
- Dashboard service. Local ? or only hosted on cypress.io ? Non free
- Can generate mp4 files (58Ko/45s)
- Paralellizable tests
- Tests can be executed in headless mode, but <u>Firefox not supported</u>.
- See also <a href="http://www.babonaux.com/2018/01/28/cypress-une-variante-en-bien-mieux-de-phantomjs/">blog1</a>, <a href="https://docs.cypress.io/guides/references/best-practices.html">best practives</a>, ...
- Based on Mocha for syntax and structure, ChaiJS for writing assertions, Chai-jQuery, SinonJS and SinonChai for stubing and spying, ... (<a href="https://docs.cypress.io/guides/references/bundled-tools.html">ref.</a>)


## Installation

- Download cypress manually from http://download.cypress.io/desktop (not accessible through npm install cypress due to proxy)
- CYPRESS_INSTALL_BINARY=path/to/cypress.zip npm install cypress


## How to start

- GUI : ./node_modules/cypress/bin/cypress open (see <a href="https://docs.cypress.io/guides/guides/command-line.html#cypress-open">options</a>)
- CLI : ./node_modules/cypress/bin/cypress run --spec 'cypress/integration/xxx.js' (see <a href="https://docs.cypress.io/guides/guides/command-line.html#cypress-run">options</a>)


## How to create a test

- https://docs.cypress.io/guides/getting-started/testing-your-app.html
- https://docs.cypress.io/guides/core-concepts/introduction-to-cypress.html
- See example files from cypress/integration/examples


## Used files

- cypress/integration: test specs
- cypress.json : global configuration
