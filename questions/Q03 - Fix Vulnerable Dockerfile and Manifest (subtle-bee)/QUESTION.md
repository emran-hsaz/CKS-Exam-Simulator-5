# Fix a Vulnerable Dockerfile and Deployment Manifest

**Domain:** Supply Chain Security · **Weight:** 7

## Requirements

1. Analyze and edit the Dockerfile at `/home/candidate/subtle-bee/build/Dockerfile`, fixing **one instruction** present in the file that is a prominent security/best-practice issue.
   - Do **not** add or remove instructions; only modify the one existing instruction with a security concern.
   - Do **not** build the Dockerfile. Building may exhaust storage and result in a zero score.

2. Analyze and edit the manifest at `/home/candidate/subtle-bee/deployment.yaml`, fixing **one field** present in the file that is a prominent security/best-practice issue.
   - Do **not** add or remove fields; only modify the one existing field with a security concern.

Should you need an unprivileged user for any of the tasks, use user `nobody` with user ID `65535`.
