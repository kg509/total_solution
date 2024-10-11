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

# 명령어가 apply가 아니면 오류 출력
if [ "$1" != "-apply" ]; then
  echo "Usage: $0 -apply"
  exit 1
fi

# data 프로젝트 디렉토리로 이동 (경로에 $script_dir/.. 추가)
cd "$script_dir/../${terraform_root}/data" || { echo "Error: data 디렉토리를 찾을 수 없습니다."; cd "$initial_dir"; exit 1; }

# Terraform 초기화
terraform init
if [ $? -ne 0 ]; then
  echo "Error: terraform init 실패"
  cd "$initial_dir"  # 이전 디렉토리로 돌아감
  exit 1
fi

# Terraform apply 실행 (auto-approve)
terraform apply -auto-approve
if [ $? -ne 0 ]; then
  echo "Error: terraform apply 실패"
  cd "$initial_dir"  # 이전 디렉토리로 돌아감
  exit 1
fi

# ArgoCD Admin Password 출력
echo -e "\n===== ArgoCD Admin Password ====="
terraform output -raw argocd_admin_password
echo -e "\n"

echo "data 프로젝트에 대해 terraform apply 완료"

# 마지막으로 원래 디렉토리로 돌아감
cd "$initial_dir"
