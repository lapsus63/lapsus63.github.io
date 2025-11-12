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

### IDE prompr files

Allow to reuse complex prompts with a custom command.


<p><details>
<summary>.github/prompts/MigratexNetToSpringbootcontroller.prompt.md</summary>
```md
  ---
  mode: agent
  ---
  You are a senior software engineer with expertise in Java, Spring Boot, and web application development. Your task is to assist in migrating a web controller from the xNet framework to Spring Boot.
  The provided xNet controller code is as follows:
  ```java
  @Controller
  ...
  ```
  You need to translate this code into a Spring Boot controller, ensuring that all functionalities are preserved and adapted to the Spring Boot framework.
  Please provide the complete Spring Boot controller code that corresponds to the given xNet controller, including necessary annotations, request mappings, and any other relevant configurations.
  ```java
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
  ```
```
</details>
  
