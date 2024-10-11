#!/bin/bash

# 현재 디렉토리의 절대 경로를 저장
initial_dir=$(pwd)

# 스크립트 파일이 있는 디렉토리로 이동 (절대 경로를 사용)
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir" || { echo "Failed to access script directory"; exit 1; }

# total_config.txt 파일을 참조 (상대 경로 유지)
config_file="$script_dir/../total_config.txt"

# total_config.txt가 존재하는지 확인
if [ ! -f "$config_file" ]; then
  echo "Error: total_config.txt 파일을 찾을 수 없습니다."
  exit 1
fi

# total_config.txt 파일에서 값을 읽어옴
source "$config_file"

# 실행할 명령어를 결정
if [ "$1" == "-apply" ]; then
  action="apply"
elif [ "$1" == "-destroy" ]; then
  action="destroy"
elif [ "$1" == "-plan" ]; then
  action="plan"
else
  echo "Usage: $0 -apply | -destroy | -plan"
  exit 1
fi

# argocd_application 프로젝트 디렉토리로 이동 (경로에 $script_dir/.. 추가)
cd "$script_dir/../${terraform_root}/argocd_application" || { echo "Error: argocd_application 디렉토리를 찾을 수 없습니다."; cd "$initial_dir"; exit 1; }

# Terraform 초기화
terraform init
if [ $? -ne 0 ]; then
  echo "Error: terraform init 실패"
  cd "$initial_dir"  # 이전 디렉토리로 돌아감
  exit 1
fi

# Terraform 명령 실행 (plan, apply, destroy)
if [ "$action" == "apply" ]; then
  terraform apply \
    -var "git_token=${git_token}" \
    -var "git_owner=${git_owner}" \
    -var "git_name=${git_name}" \
    -auto-approve
elif [ "$action" == "destroy" ]; then
  terraform destroy \
    -var "git_token=${git_token}" \
    -var "git_owner=${git_owner}" \
    -var "git_name=${git_name}" \
    -auto-approve
elif [ "$action" == "plan" ]; then
  terraform plan \
    -var "git_token=${git_token}" \
    -var "git_owner=${git_owner}" \
    -var "git_name=${git_name}"
fi

if [ $? -ne 0 ]; then
  echo "Error: terraform $action 실패"
  cd "$initial_dir"  # 이전 디렉토리로 돌아감
  exit 1
fi

echo "argocd_application 프로젝트에 대해 terraform $action 완료"

# 마지막으로 원래 디렉토리로 돌아감
cd "$initial_dir"
