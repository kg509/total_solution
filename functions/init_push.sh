#!/bin/bash

# 현재 디렉토리의 절대 경로를 저장
initial_dir=$(pwd)

# 스크립트 파일이 있는 디렉토리로 이동
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir" || { echo "Failed to access script directory"; exit 1; }

# total_config.txt 파일을 참조
config_file="$script_dir/../total_config.txt"

# total_config.txt가 존재하는지 확인
if [ ! -f "$config_file" ]; then
  echo "Error: total_config.txt 파일을 찾을 수 없습니다."
  exit 1
fi

# total_config.txt 파일에서 값을 읽어옴
source "$config_file"

# gitaction_ecr_root 경로를 스크립트 기준으로 변환
resolved_gitaction_ecr_root="$script_dir/../$gitaction_ecr_root"

# gitaction_ecr_root 디렉토리에 .git이 있다면 삭제 (반복문 전에 실행)
if [ -d "${resolved_gitaction_ecr_root}/.git" ]; then
  echo "Removing the existing .git directory from $resolved_gitaction_ecr_root"
  rm -rf "${resolved_gitaction_ecr_root}/.git"
fi

# repo_addr와 target_repo 배열을 함께 순회하여 경로 구성
for i in "${!repo_addr[@]}"; do
  target="${resolved_gitaction_ecr_root}/${target_repo[$i]}"  # resolved_gitaction_ecr_root와 target_repo를 조합하여 타겟 경로 구성
  repo=${repo_addr[$i]}  # 리포지토리의 SSH 주소

  echo "Processing target: $target with repository: $repo"

  # 디렉토리 존재 여부 확인, 없으면 에러 출력
  if [ ! -d "$target" ]; then
    echo "Error: Directory $target does not exist. Please ensure the repository is prepared."
    cd "$initial_dir"
    exit 1
  fi

  # 각 repo 디렉토리에서 .git 디렉토리가 있다면 삭제 (반복문 내에서 각 리포지토리마다 처리)
  if [ -d "${target}/.git" ]; then
    echo "Removing the existing .git directory from $target"
    rm -rf "${target}/.git"
  fi

  # 대상 디렉토리로 이동
  cd "$target" || { echo "Failed to change directory to $target"; cd "$initial_dir"; exit 1; }

  # git 초기화 및 원격 저장소 설정
  git init
  git remote add origin "$repo"

  # 첫 커밋 및 브랜치 설정
  git add .
  git commit -m "Initial commit for $target"
  git branch -M main

  # 원격 저장소로 푸시
  git push -u origin main

  # 원래 경로로 돌아오기
  cd "$script_dir"
done

echo "Repositories have been initialized and pushed successfully!"

# 마지막으로 원래 디렉토리로 돌아감
cd "$initial_dir"
