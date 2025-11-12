# IA

## Documentation

- 

##  Overview

- Context Window = Prompt System + Previous Questions & Answers + Prompt + Other elements (documents, images, ...)
- Context Window = limited to x tokens (~128K). One word = 1 to 3 tokens (see [Tokenizer](https://platform.openai.com/tokenizer))
- [LLM Leaderboard](https://artificialanalysis.ai/leaderboards/models) - Comparison of over 100 AI models
- GitHub Copilot licences: Free (not confidential) ; Pro & Pro+ ; Business ; Entreprise

## Prompting tips

- Provide examples of what you expect.
- Include: Role & Language style ; format/length ; entries/references ; emotion ; objective ; examples
- Cut a complex request in subtasks

### IDE prompt files

Allow to reuse complex prompts with a custom command.


<p><details>
<summary>.github/prompts/MigratexNetToSpringbootcontroller.prompt.md</summary>
  
```md
  ---
  mode: agent
  ---
  You are a senior software engineer with expertise in Java, Spring Boot, and web application development. Your task is to assist in migrating a web controller from the xNet framework to Spring Boot.
  The provided xNet controller code is as follows:
  ---java
  @Controller
  ...
  ---
  You need to translate this code into a Spring Boot controller, ensuring that all functionalities are preserved and adapted to the Spring Boot framework.
  Please provide the complete Spring Boot controller code that corresponds to the given xNet controller, including necessary annotations, request mappings, and any other relevant configurations.
  ---java
  @RestController
  @RequestMapping("/api")
  public class MySpringBootController {
  @GetMapping("/example")
  public ResponseEntity<String> exampleMethod() {
  // Implement the logic here
  return ResponseEntity.ok("Example response");
  }
  // Add other methods and mappings as needed
  }
  ---
```

</details>

* Repository-wide custom instructions, which apply to all requests made in the context of a repository: `.github/copilot-instructions.md`
* Path-specific custom instructions, which apply to requests made in the context of files that match a specified path: `.github/instructions/NAME.instructions.md` ; use `*applyTo: "**/*.ts,**/*.tsx"` in the header.

<p><details>
<summary>.github/copilot-instructions.md</summary>
  
```md
# GitHub Copilot - Instructions par défaut

Ce fichier définit les règles et bonnes pratiques à suivre pour l'utilisation de GitHub Copilot dans ce projet.

## Langages et Frameworks
- Utiliser **Java 17** pour le backend.
- Utiliser **Spring Boot 3.4.2** pour l’API REST.
- Utiliser **Angular 19** pour le frontend.

## Conventions de nommage
- Variables et méthodes : camelCase
- Classes : PascalCase
- Fichiers : kebab-case pour Angular, camelCase ou PascalCase pour Java

## Tests
- Générer des tests unitaires avec **JUnit 5** pour le backend.
- Utiliser **Jasmine/Karma** pour les tests frontend Angular.

## Annotations et bonnes pratiques Spring
- Utiliser les annotations Spring appropriées : `@RestController`, `@Service`, `@Repository`, `@Entity`, etc.
- Respecter l'architecture en couches : contrôleur, service, repository, modèle.

## Documentation
- Ajouter des commentaires clairs pour les méthodes complexes.
- Documenter les endpoints REST dans les contrôleurs.

## Sécurité et qualité
- Valider les entrées utilisateur côté backend et frontend.
- Utiliser des exceptions personnalisées pour la gestion des erreurs.
- Respecter les bonnes pratiques de gestion des dépendances et de configuration.

## CI/CD
- Prévoir des scripts pour l'intégration continue et le déploiement.
```

</details>


<p><details>
<summary>.chatmodes/tech-debt-remediation-plan.chatmode.md</summary>

```md
---
description: 'Generate technical debt remediation plans for code, tests, and documentation.'
tools: ['changes', 'codebase', 'editFiles', 'extensions', 'fetch', 'findTestFiles', 'githubRepo', 'new', 'openSimpleBrowser', 'problems', 'runCommands', 'runTasks', 'runTests', 'search', 'searchResults', 'terminalLastCommand', 'terminalSelection', 'testFailure', 'usages', 'vscodeAPI', 'github']
---
# Technical Debt Remediation Plan
Generate comprehensive technical debt remediation plans. Analysis only - no code modifications. Keep recommendations concise and actionable. Do not provide verbose explanations or unnecessary details.

```
  
</details></p>

