#!/bin/bash

set -e

sleep 12
# Assign arguments to variables
git_provider=$1
git_owner=$2
gitops_token=$3
git_username=$4
cluster_name=$5

# Save the token to a file (for authentication)
echo "$gitops_token" > token.txt

# Authenticate with GitHub
if [ "$git_provider" == "github" ];then 
  gh auth login --git-protocol https --with-token < token.txt
elif [ "$git_provider" == "gitlab" ];then 
  glab auth login --stdin < token.txt
fi

if [ $? -ne 0 ]; then
    echo "{\"code\": 1, \"status\": 401, \"error\": \"Authentication failed.\"}"
    exit 1
fi

# Clone the repository
if [ "$git_provider" == "github" ]; then
  url="https://$gitops_token@github.com/$git_owner/gitops.git"
elif [ "$git_provider" == "gitlab" ]; then
  url="https://oauth2:$gitops_token@gitlab.com/$git_owner/gitops.git"
else
  echo "{\"code\": 1, \"status\": 400, \"error\": \"Unsupported git provider.\"}"
  exit 1
fi

git clone $url
git config --global user.name "$git_owner"
git config --global user.email "1@gmail.com"

# Change directory to the cloned repository
cd gitops || { echo "{\"code\": 1, \"status\": 500, \"error\": \"Failed to change directory to gitops\"}"; exit 1; }

echo "Repository cloned successfully"

# Define arrays for source and destination files
srcfiles=("/kustomization.yaml"
          "/cloudflareissuer.yaml"
          "/cloudflareissuer-dev.yaml"
          "/cloudflareissuer-prod.yaml"
          "/cloudflareissuer-stag.yaml")

destfiles=("/registry/clusters/${cluster_name}/components/argocd/kustomization.yaml"
           "/registry/clusters/${cluster_name}/components/argocd/cloudflareissuer.yaml"
           "/registry/environments/development/cloudflareissuer.yaml"
           "/registry/environments/production/cloudflareissuer.yaml"
           "/registry/environments/staging/cloudflareissuer.yaml")

current_dir=$(pwd)
# Loop through files
for i in "${!srcfiles[@]}"; do
  srcFile="/workspace""${srcfiles[i]}"
  destFile="${current_dir}${destfiles[i]}"

  # Check if the destination file exists
  if [ ! -f "$destFile" ]; then
    # If the destination file does not exist, create it and copy the contents of the source file
    cat "$srcFile" > "$destFile"
    
    if [ $? -eq 0 ]; then
      echo "Contents of $srcFile written to $destFile"
    else
      echo "Error copying contents of $srcFile to $destFile"
      exit 1
    fi
  else
    cat "$srcFile" > "$destFile"
    echo "Destination file already exists: $destFile"
  fi
done

# Add, commit, and push changes
git add .
git commit -m "add cloudflare issuer"
# Attempt to push changes to the branch
git push 
