#!/usr/bin/bash

set -o pipefail

PROJECT=ynab-sheets-001
LOCATION=us-west1
SERVICE=uv-monorepo-example
REPO=projects/${PROJECT}/locations/${LOCATION}/repositories/artifacts

ensure_repo() {
    repo=projects/${PROJECT}/locations/${LOCATION}/repositories/artifacts
    if gcloud artifacts repositories describe $repo >& /dev/null; then
	return 0
    fi
    gcloud artifacts repositories create \
	   --location=$LOCATION \
	   --repository-format=DOCKER \
	   $REPO &&
	gcloud artifacts repositories set-cleanup-policies \
	       --policy=../repository-cleanup-policy.json \
	       $REPO
    return $?
}

uv sync --all-packages &&
    docker build -t ${LOCATION}-docker.pkg.dev/${PROJECT}/artifacts/${SERVICE}-image:latest -f apps/${SERVICE}/Dockerfile . &&
    docker push ${LOCATION}-docker.pkg.dev/${PROJECT}/artifacts/${SERVICE}-image:latest &&
    gcloud run deploy \
	   --project=${PROJECT} \
	   --image=${LOCATION}-docker.pkg.dev/${PROJECT}/artifacts/${SERVICE}-image \
	   --base-image=${LOCATION}-docker.pkg.dev/serverless-runtimes/google-22/runtimes/python313 \
	   --region=${LOCATION} \
           --no-allow-unauthenticated \
	   --concurrency=1 \
	   --max-instances=1 \
	   --timeout=60 \
	   --cpu=0.1 \
	   --memory=256Mi \
	   ${SERVICE} &&
    docker image ls -f "reference=${LOCATION}-docker.pkg.dev/${PROJECT}/artifacts/${SERVICE}-image*" |
	tail -n +2 | awk '$2 != "latest" {print $3}' | xargs -r docker image rm
