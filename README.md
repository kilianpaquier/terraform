# terraform <!-- omit in toc -->

<p align="center">
  <img alt="GitLab Release" src="https://img.shields.io/gitlab/v/release/kilianpaquier%2Fterraform?gitlab_url=https%3A%2F%2Fgitlab.com&include_prereleases&sort=semver&style=for-the-badge">
  <img alt="GitLab Issues" src="https://img.shields.io/gitlab/issues/open/kilianpaquier%2Fterraform?gitlab_url=https%3A%2F%2Fgitlab.com&style=for-the-badge">
  <img alt="GitLab License" src="https://img.shields.io/gitlab/license/kilianpaquier%2Fterraform?gitlab_url=https%3A%2F%2Fgitlab.com&style=for-the-badge">
  <img alt="GitLab CICD" src="https://img.shields.io/gitlab/pipeline-status/kilianpaquier%2Fterraform?gitlab_url=https%3A%2F%2Fgitlab.com&branch=main&style=for-the-badge">
</p>

---

## Useful resources

### OVH

- Application and rights management : https://www.ovh.com/manager/#/iam/api-keys

#### Traefik DNS rights

```txt
POST: /domain/zone/kilianpaquier.dev/record
POST: /domain/zone/kilianpaquier.dev/refresh
DELETE: /domain/zone/kilianpaquier.dev/record/*
```

```json
{
  "accessRules": [
    { "method": "POST", "path": "/domain/zone/kilianpaquier.dev/record" },
    { "method": "DELETE", "path": "/domain/zone/kilianpaquier.dev/record/*" },
    { "method": "POST", "path": "/domain/zone/kilianpaquier.dev/refresh" }
  ]
}
```
