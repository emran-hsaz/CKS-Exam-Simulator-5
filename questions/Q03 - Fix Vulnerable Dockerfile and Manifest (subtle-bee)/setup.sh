#!/bin/bash
echo "Setting up Q3 — subtle-bee Dockerfile and manifest..."
mkdir -p /home/candidate/subtle-bee/build
cat > /home/candidate/subtle-bee/build/Dockerfile <<'DF'
FROM alpine:3.19
RUN apk add --no-cache curl bash
COPY app.sh /app/app.sh
RUN chmod +x /app/app.sh
ENV APP_ENV=production
EXPOSE 8080
USER root
CMD ["/app/app.sh"]
DF
cat > /home/candidate/subtle-bee/deployment.yaml <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: subtle-bee
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: subtle-bee
  template:
    metadata:
      labels:
        app: subtle-bee
    spec:
      containers:
        - name: subtle-bee
          image: subtle-bee:1.0
          ports:
            - containerPort: 8080
          securityContext:
            privileged: true
YAML
echo "Done."
echo "  Dockerfile: /home/candidate/subtle-bee/build/Dockerfile"
echo "  Manifest:   /home/candidate/subtle-bee/deployment.yaml"
