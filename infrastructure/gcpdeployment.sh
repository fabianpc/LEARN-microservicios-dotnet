#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Google Cloud replacement for:
# - Azure Resource Group
# - Azure Service Bus namespace + queue + topics + subscriptions
# - Azure Container Apps Environment
#
# Notes:
# 1) GCP has no direct equivalent to Azure Resource Groups.
#    Resources are organized under a PROJECT.
# 2) Google Cloud Pub/Sub does not have a separate "namespace" resource like Azure Service Bus.
# 3) Pub/Sub does not have a standalone queue object exactly like Azure Service Bus Queue.
#    The closest managed equivalent is a TOPIC plus a SUBSCRIPTION.
# 4) There is no direct "Container Apps Environment" object in GCP matching Azure Container Apps Env.
#    The closest simple managed target is Cloud Run.
# ==============================

# ---------- REQUIRED VARIABLES ----------
PROJECT_ID="your-gcp-microservicios"
PROJECT_NUMBER=""   # optional; if empty, script will detect it
REGION="us-central1"

# Logical replacements for your Azure names
PUBSUB_PREFIX="sb-age"
QUEUE_TOPIC_NAME="pickage"
QUEUE_SUBSCRIPTION_NAME="pickage-sub"
ADULTS_TOPIC_NAME="adultstopic"
ADULTS_SUBSCRIPTION_NAME="S1-adults"
CHILDREN_TOPIC_NAME="childrentopic"
CHILDREN_SUBSCRIPTION_NAME="S1-children"

# Cloud Run placeholder service (replacement for Container Apps environment idea)
CLOUD_RUN_SERVICE_NAME="env-microservicios-placeholder"
CLOUD_RUN_IMAGE="us-docker.pkg.dev/cloudrun/container/hello"

# ---------- PREREQUISITES ----------
command -v gcloud >/dev/null 2>&1 || { echo "Error: gcloud CLI is not installed."; exit 1; }

# ---------- PROJECT SETUP ----------
gcloud config set project "$PROJECT_ID"

if [[ -z "$PROJECT_NUMBER" ]]; then
  PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
fi

echo "Using PROJECT_ID=$PROJECT_ID"
echo "Using PROJECT_NUMBER=$PROJECT_NUMBER"
echo "Using REGION=$REGION"

# ---------- ENABLE REQUIRED APIS ----------
gcloud services enable \
  pubsub.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com

# ---------- PUB/SUB RESOURCES ----------
# Azure Service Bus namespace -> not needed in GCP, but we keep a prefix for naming.

# Azure queue "pickage" -> Pub/Sub topic + subscription
if ! gcloud pubsub topics describe "$QUEUE_TOPIC_NAME" >/dev/null 2>&1; then
  gcloud pubsub topics create "$QUEUE_TOPIC_NAME"
else
  echo "Topic $QUEUE_TOPIC_NAME already exists; skipping."
fi

if ! gcloud pubsub subscriptions describe "$QUEUE_SUBSCRIPTION_NAME" >/dev/null 2>&1; then
  gcloud pubsub subscriptions create "$QUEUE_SUBSCRIPTION_NAME" \
    --topic="$QUEUE_TOPIC_NAME"
else
  echo "Subscription $QUEUE_SUBSCRIPTION_NAME already exists; skipping."
fi

# Azure topic "adultstopic" + subscription S1
if ! gcloud pubsub topics describe "$ADULTS_TOPIC_NAME" >/dev/null 2>&1; then
  gcloud pubsub topics create "$ADULTS_TOPIC_NAME"
else
  echo "Topic $ADULTS_TOPIC_NAME already exists; skipping."
fi

if ! gcloud pubsub subscriptions describe "$ADULTS_SUBSCRIPTION_NAME" >/dev/null 2>&1; then
  gcloud pubsub subscriptions create "$ADULTS_SUBSCRIPTION_NAME" \
    --topic="$ADULTS_TOPIC_NAME"
else
  echo "Subscription $ADULTS_SUBSCRIPTION_NAME already exists; skipping."
fi

# Azure topic "childrentopic" + subscription S1
if ! gcloud pubsub topics describe "$CHILDREN_TOPIC_NAME" >/dev/null 2>&1; then
  gcloud pubsub topics create "$CHILDREN_TOPIC_NAME"
else
  echo "Topic $CHILDREN_TOPIC_NAME already exists; skipping."
fi

if ! gcloud pubsub subscriptions describe "$CHILDREN_SUBSCRIPTION_NAME" >/dev/null 2>&1; then
  gcloud pubsub subscriptions create "$CHILDREN_SUBSCRIPTION_NAME" \
    --topic="$CHILDREN_TOPIC_NAME"
else
  echo "Subscription $CHILDREN_SUBSCRIPTION_NAME already exists; skipping."
fi

# ---------- CLOUD RUN PLACEHOLDER ----------
# Azure Container Apps Environment does not map 1:1 to GCP.
# This creates a simple Cloud Run service as the closest fully managed container platform.
# Replace the image with your own container image later.
if ! gcloud run services describe "$CLOUD_RUN_SERVICE_NAME" --region="$REGION" >/dev/null 2>&1; then
  gcloud run deploy "$CLOUD_RUN_SERVICE_NAME" \
    --image="$CLOUD_RUN_IMAGE" \
    --region="$REGION" \
    --platform=managed \
    --allow-unauthenticated
else
  echo "Cloud Run service $CLOUD_RUN_SERVICE_NAME already exists; skipping deploy."
fi

echo "Done. Resources created in Google Cloud:"
echo "- Pub/Sub topic: $QUEUE_TOPIC_NAME"
echo "- Pub/Sub subscription: $QUEUE_SUBSCRIPTION_NAME"
echo "- Pub/Sub topic: $ADULTS_TOPIC_NAME"
echo "- Pub/Sub subscription: $ADULTS_SUBSCRIPTION_NAME"
echo "- Pub/Sub topic: $CHILDREN_TOPIC_NAME"
echo "- Pub/Sub subscription: $CHILDREN_SUBSCRIPTION_NAME"
echo "- Cloud Run service: $CLOUD_RUN_SERVICE_NAME"
