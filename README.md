# VersionVigilante

[![Build Status](https://travis-ci.com/bcbi/VersionVigilante.jl.svg?branch=master)](https://travis-ci.com/bcbi/VersionVigilante.jl)
[![Codecov](https://codecov.io/gh/bcbi/VersionVigilante.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bcbi/VersionVigilante.jl)

VersionVigilante enforces the rule that all pull requests must increase the version number in your Julia package's `Project.toml` file. This helps automate the continuous delivery (CD) process for your package.

A good description of the CD workflow for Julia packages is available here: https://white.ucc.asn.au/2019/09/28/Continuous-Delivery-For-Julia-Packages.html

## Basic usage

```julia
VersionVigilante.main("https://github.com/MYUSERNAME/MYPACKAGE.jl")
```

## Using on Travis CI

Add the following to your `.travis.yml` file:
```yaml
jobs:
  include:
    - stage: VersionVigilante
      julia: "1.2"
      script:
        - set -e
        - julia -e 'using Pkg; Pkg.add(Pkg.PackageSpec(url = "https://github.com/bcbi/VersionVigilante.jl"))'
        - julia -e 'using VersionVigilante; VersionVigilante.main("https://github.com/MYUSERNAME/MYPACKAGE.jl")'
      after_success: true
```
