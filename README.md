# terraform <!-- omit in toc -->

<p align="center">
  <img alt="GitHub Release" src="https://img.shields.io/github/v/release/kilianpaquier/terraform?include_prereleases&sort=semver&style=for-the-badge">
  <img alt="GitHub Issues" src="https://img.shields.io/github/issues-raw/kilianpaquier/terraform?style=for-the-badge">
  <img alt="GitHub License" src="https://img.shields.io/github/license/kilianpaquier/terraform?style=for-the-badge">
  <img alt="GitHub Actions" src="https://img.shields.io/github/actions/workflow/status/kilianpaquier/terraform/integration.yml?style=for-the-badge">
</p>

---

## Ressources utiles

### OVH

- Gestion des applications et droits : https://www.ovh.com/manager/#/iam/api-keys

#### Modification de la zone DNS

```json
{
  "accessRules": [
    { "method": "POST", "path": "/domain/zone/kilianpaquier.ovh/record" },
    { "method": "DELETE", "path": "/domain/zone/kilianpaquier.ovh/record/*" },
    { "method": "POST", "path": "/domain/zone/kilianpaquier.ovh/refresh" }
  ]
}
```
