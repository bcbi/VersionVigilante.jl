## Using VersionVigilante with Bors-NG

These are the instructions for using VersionVigilante with
[Bors](https://github.com/bors-ng/bors-ng). If you do not use Bors on your
repository, [click here](README.md) for instructions.

## Step 1 (required): Create `VersionVigilante_bors.yml` workflow

Add the following GitHub Actions workflow to your repo in a workflow file
named `.github/workflows/VersionVigilante_bors.yml`:
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
        id: versionvigilante_main
        run: |
          julia -e 'using Pkg; Pkg.add("VersionVigilante")'
          julia -e 'using VersionVigilante; VersionVigilante.main("https://github.com/${{ github.repository }}")'
```


## Step 2 (required): Update `bors.toml` file

Update your `bors.toml` file to include `VersionVigilante` in the list of
required statuses. For example, your `bors.toml` file may look like this:
```toml
status = [
    "Travis CI - Branch",
    "VersionVigilante",
]
```

## Step 3 (optional, but highly recommended): Create `VersionVigilante_pull_request.yml` workflow

Add the following GitHub Actions workflow to your repo in a workflow file
named `.github/workflows/VersionVigilante_pull_request.yml`:
```yaml
name: VersionVigilante

on: pull_request

jobs:
  VersionVigilante:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1.0.0
      - uses: julia-actions/setup-julia@latest
      - name: VersionVigilante.main
        id: versionvigilante_main
        run: |
          julia -e 'using Pkg; Pkg.add("VersionVigilante")'
          julia -e 'using VersionVigilante; VersionVigilante.main("https://github.com/${{ github.repository }}")'
      - name: ✅ Un-Labeller (if success)
        if: (steps.versionvigilante_main.outputs.compare_versions == 'success') && (success() || failure())
        continue-on-error: true
        uses: actions/github-script@0.3.0
        with:
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            github.issues.removeLabel({...context.issue, name: 'needs version bump'})
      - name: ❌ Labeller (if failure)
        if: (steps.versionvigilante_main.outputs.compare_versions == 'failure') && (success() || failure())
        continue-on-error: true
        uses: actions/github-script@0.3.0
        with:
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            github.issues.addLabels({...context.issue, labels: ['needs version bump']})
```
