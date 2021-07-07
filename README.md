# Docker Build for SOS Web GUI & SOS

## Overview

This will generate a CentOS 7 image with the latest version of:

* https://github.com/nick-enoent/sosdb-ui
* https://github.com/ovis-hpc/sos


## Getting Started

```bash
git clone --recursive https://github.com/grigorescu/ovis_docker.git
docker build -t ovis .
docker run -p 8000:8000 ovis
```

Then, visit http://127.0.0.1:8000 on your machine, and login with username `admin`, password `pass`.

## Current State

This was just an initial pass of a proof of concept.
