# Renovate Overview

## Documentation

- 

## Overview

## Project configuration


<p>
<details>
<summary>renovate.jsonw</summary>

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "branchPrefix": "fix/REF-0000_",
  "branchName": "{{branchPrefix}}{{additionalBranchPrefix}}{{branchTopic}}",
  "commitMessage": "{{commitMessagePrefix}}{{commitMessageAction}} {{commitMessageTopic}} {{commitMessageExtra}} {{commitMessageSuffix}}",
  "commitMessagePrefix": "REF-0000_",
  "commitMessageTopic": "{{depName}}",
  "git-submodules": {
    "enabled": true
  },
  "packageRules": [
    {
      "_1": "Keep Postgre v16",
      "matchDatasources": ["docker"],
      "matchPackageNames": ["postgres"],
      "allowedVersions": "16.x"
    },
    {
      "_1": "Exclude some library (maven pom.xml) version",
      "matchPackageNames": ["jfrog-cli-v2-jf"],
      "allowedVersions": "!2.77.0, !2.76.1"
    }

  ]
}

```

</details
