#!/bin/bash

# 실행할 명령어를 결정합니다.
if [ "$1" == "-apply" ]; then
  action="apply"
elif [ "$1" == "-destroy" ]; then
  action="destroy"
else
  echo "Usage: $0 -apply | -destroy"
  exit 1
fi

# apply인 경우 순차적으로 실행
if [ "$action" == "apply" ]; then
  ./functions/eks.sh -apply
  ./functions/karpenter.sh -apply
  ./functions/argocd.sh -apply
  ./functions/github.sh -apply
  ./functions/init_push.sh
  ./functions/argocd_application.sh -apply
  ./functions/plg.sh -apply
  ./functions/data.sh -apply

# destroy인 경우 역순으로 실행하되, data와 init_push는 제외
elif [ "$action" == "destroy" ]; then
  ./functions/plg.sh -destroy
  ./functions/argocd_application.sh -destroy
  ./functions/github.sh -destroy
  ./functions/argocd.sh -destroy
  ./functions/karpenter.sh -destroy
  ./functions/eks.sh -destroy
fi

echo "Terraform $action 명령이 완료되었습니다."
