output "domain" {
  value = "kilianpaquier.dev"
}

output "labels" {
  value = [
    {
      color       = "#B60205"
      description = "This change is breaking"
      name        = "breaking"
    },
    {
      color       = "#D73A4A"
      description = "Something isn't working"
      name        = "bug"
    },
    {
      color       = "#0366D6"
      description = "This was made by dependabot"
      name        = "dependabot"
    },
    {
      color       = "#0052CC"
      description = "Updates some dependencies"
      name        = "dependencies"
    },
    {
      color       = "#0075CA"
      description = "Improvements or additions to documentation"
      name        = "documentation"
    },
    {
      color       = "#CFD3D7"
      description = "This issue or pull request already exists"
      name        = "duplicate"
    },
    {
      color       = "#A2EEEF"
      description = "New feature or request"
      name        = "enhancement"
    },
    {
      color       = "#7057FF"
      description = "Good for newcomers"
      name        = "good first issue"
    },
    {
      color       = "#008672"
      description = "Extra attention is needed"
      name        = "help wanted"
    },
    {
      color       = "#E4E669"
      description = "This doesn't seem right"
      name        = "invalid"
    },
    {
      color       = "#B60205"
      description = "A major dependency update"
      name        = "major"
    },
    {
      color       = "#D876E3"
      description = "Further information is requested"
      name        = "question"
    },
    {
      color       = "#5319E7"
      description = "This was made by renovatebot"
      name        = "renovate"
    },
    {
      color       = "#D93F0B"
      description = "Improvements or additions to testcases"
      name        = "test"
    },
    {
      color       = "#D4C5F9"
      description = "This will not be worked on"
      name        = "wontfix"
    }
  ]
}

output "public_keys" {
  value = {
    desktop     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA4gpcZXGcMfKMZyRvLzuav955wMV7FPjdRboPKxvuLf desktop.9th-gen.ryzen"
    laptop      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtbXuVKV/wwO8q2CRsAGqftaiqOKe0NpZUnMA+Zn1+w laptop.12th-gen.intel-core"
    work-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONZytSCpwTrg7RkQ/RnvNzMRj7zOB94NWMxXlAaYLRA laptop.200-series.ryzen"
  }
}
