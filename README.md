# VersionVigilante

[![Build Status](https://travis-ci.com/bcbi/VersionVigilante.jl.svg?branch=master)](https://travis-ci.com/bcbi/VersionVigilante.jl)
[![Codecov](https://codecov.io/gh/bcbi/VersionVigilante.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bcbi/VersionVigilante.jl)

VersionVigilante enforces the rule that all pull requests must increase the version number in your Julia package's `Project.toml` file. This helps automate the continuous delivery (CD) process for your package.

A good description of the CD workflow for Julia packages is available here: https://white.ucc.asn.au/2019/09/28/Continuous-Delivery-For-Julia-Packages.html

## Basic usage

```julia
VersionVigilante.main("https://github.com/MyUsername/MyPackage.jl")
```

```julia
VersionVigilante.main("https://example.com/foo/bar/baz/MyPackage.jl")
```

## Using on GitHub Actions

Add the following workflow to your repo in a workflow file
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
        # BEGIN: Uncomment these lines if this is a private repository
        # run: |
        #   julia -e 'using Pkg; Pkg.add("VersionVigilante")'
        #   julia -e 'using VersionVigilante; VersionVigilante.main("https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}")'
        # END: Uncomment these lines if this is a private repository
        # BEGIN: Comment out these lines if this is NOT a private repository
        run: |
          julia -e 'using Pkg; Pkg.add("VersionVigilante")'
          julia -e 'using VersionVigilante; VersionVigilante.main("https://github.com/${{ github.repository }}")'
        # END: Comment out these lines if this is NOT a private repository
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

## Using on Travis CI

Add the following to your `.travis.yml` file.
Make sure to replace `MYUSERNAME` and `MYPACKAGE` with the correct values.
```yaml
jobs:
  include:
    - stage: VersionVigilante
      if: type = pull_request OR branch != master
      julia: "1.2"
      script:
        - set -e
        - julia -e 'using Pkg; Pkg.add("VersionVigilante")'
        - julia -e 'using VersionVigilante; VersionVigilante.main("https://github.com/MYUSERNAME/MYPACKAGE.jl")'
      after_success: true
```

## Using with Bors-NG

If you use [Bors](https://github.com/bors-ng/bors-ng) on your repository,
[click here](instructions_bors.md) for instructions.
