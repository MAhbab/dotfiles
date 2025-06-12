#!/bin/bash
set -euo pipefail

BUCKET_NAME="us-east4-symbiosys-prod-d2ba7294-bucket"
DAG_PATHS=$(gsutil ls "gs://$BUCKET_NAME/logs/" | sed 's|gs://'"$BUCKET_NAME"'/logs/||' | sed 's|/||')

DAG_ID="dag_id=reporting_intraday"

#TASK_PATHS=$(gsutil ls "gs://$BUCKET_NAME/logs/$DAG_ID/" | sed 's|.*/||' | sed 's|/||')
#LATEST_EXEC=$(gsutil ls "gs://$BUCKET_NAME/logs/$DAG_ID/" | tail -n1)

TODAY=$(date +"%Y-%m-%dT%H")
gsutil ls "gs://$BUCKET_NAME/logs/$DAG_ID/run_id=scheduled__${TODAY}*" 2>/dev/null
