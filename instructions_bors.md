## Using VersionVigilante with Bors-NG

These are the instructions for using VersionVigilante with
[Bors](https://github.com/bors-ng/bors-ng). If you do not use Bors on your
repository, [click here](README.md) for instructions.

## Step 1: Create GitHub Actions workflow

Add the following workflow to your repo in a workflow file
named `.github/workflows/VersionVigilante.yml`.

```yaml
name: VersionVigilante

on:
  push:
    branches:    
      - staging
      - trying

jobs:
  VersionVigilante:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1.0.0
      - uses: julia-actions/setup-julia@latest
      - name: VersionVigilante.main
        run: |
          julia -e 'using Pkg; Pkg.add(Pkg.PackageSpec(url = "https://github.com/bcbi/VersionVigilante.jl"))'
          julia -e 'using VersionVigilante; VersionVigilante.main("https://github.com/${{ github.repository }}")'

```


## Step 2: Update `bors.toml` file

Update your `bors.toml` file to include `VersionVigilante` in the list of
required statuses. For example, your `bors.toml` file may look like this:
```toml
status = [
    "Travis CI - Branch",
    "VersionVigilante",
]
```
