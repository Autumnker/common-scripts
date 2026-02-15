#!/bin/bash
set -euo pipefail

# Set color macro
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NC='\033[0m'  # No Color

# Capture parameters
script_name="$0"
script_name="${script_name##*/}"
if [ $# != 0 ]; then
    echo "useage: ${script_name}"
    echo -e "${BLUE}Recursively find all Git repositories from the current directory 
and synchronize their corresponding remote repository main branches.${NC}"
    exit 1
fi

# Directories to be excluded from search
#IGNORE_DIRS=("node_modules" "vendor" ".cache")
IGNORE_DIRS=""

# List of main branch names
MAIN_BRANCHES=("main" "master")

# Create the list of ignored parameters
FIND_ARGS=()
if [ "$IGNORE_DIRS" != "" ]; then
    for dir in "${IGNORE_DIRS[@]}"; do
        FIND_ARGS+=(-path "$(pwd)/$dir" -prune -o)
    done
fi

# Create an array of repository directories
mapfile -t repo_dirs < <(
find "$(pwd)" "${FIND_ARGS[@]}" -type d -name ".git" -print \
        | sed 's/\/.git\/*//' \
        | sort -u
)

# Verify if any repositories are found
if [ ${#repo_dirs[@]} -eq 0 ]; then
    echo -e "${RED} No repositories found${NC}"
    exit 0
fi

# Display repositories to be updated
echo -e "${BLUE} --------------------------------------------------${NC}"
echo "Number of repositories found : ${#repo_dirs[@]}"
echo -e "${BLUE} --------------------------------------------------${NC}"
for repo in "${repo_dirs[@]}"; do
    echo "- $repo"
done

# Define the failure handling function
fail_repo_max_len=0
fail_count=0
fail_repo_name=()
declare -A fail_repo_reason
fail_handle(){
    local repo_name="$1"
    local fail_reason="$2"
    local name_len="${#repo_name}"
    (( fail_count+=1 ))
    fail_repo_name+=("$repo_name")
    fail_repo_reason["$repo_name"]="$fail_reason"

    if [ "$fail_repo_max_len" -lt "$name_len" ]; then
        fail_repo_max_len="$name_len"
    fi
}

# Execute operations on each repository
repo_count=0
repo_num="${#repo_dirs[@]}"
for repo in "${repo_dirs[@]}"; do
    (( repo_count+=1 ))
    echo -e "${BLUE} --------------------------------------------------${NC}"
    echo -e "[${repo_count}/${repo_num}] Processing repository: '$repo'"
    cd "$repo"  || { echo -e "${RED} Failed to enter directory: '$repo', skipping${NC}"; fail_handel "$repo" "Failed to enter directory"; continue; }
    
    # Get the fetch URL
    remote_info=$(git remote -v 2>/dev/null)
    if [ -z "$remote_info" ]; then
        echo -e "${YELLOW} No remote repository configured for this repository, skipping${NC}"
        fail_handle "$repo" "No remote repository configured for this repository"
        continue
    fi
    fetch_url=$(echo "$remote_info" | grep -i 'fetch' | awk '{print $2}' | head -n1)
    echo -e "fetch url=${GREEN}${fetch_url}${NC}"

    # Extract the remote repository name
    remote_name=$(echo "$remote_info" | awk '{print $1}' | head -n1 | uniq)

    # Switch to the main branch
    branch_switched=false
    MAIN_BRANCH=""
    for branch in "${MAIN_BRANCHES[@]}"; do
        if git show-ref --verify --quiet "refs/heads/$branch"; then
            git checkout "$branch" 2>/dev/null
            branch_switched=true
            MAIN_BRANCH="$branch"
            break
        fi
    done
    if [ "$branch_switched" = false ]; then
        echo -e "${RED} Main branch not found, skipping${NC}"
        fail_handle "$repo" "Main branch not found"
        continue
    fi

    # Execute the git pull operation
    if ! git pull "$remote_name" "$MAIN_BRANCH"; then
        echo -e "${RED} Pull operation failed${NC}"
        fail_handle "$repo" "Pull operation failed"
        continue
    fi
done

# Print error message
if [ "$fail_count" != 0 ]; then
    echo -e "${RED} --------------------------------------------------${NC}"
    echo -e "${RED}failed task:${NC}"
    for repo in "${fail_repo_name[@]}"; do
        printf "%-${fail_repo_max_len}s: ${YELLOW}%-s${NC}\n" "$repo" " ${fail_repo_reason[$repo]}"
    done
    echo -e "${RED} --------------------------------------------------${NC}"
else
    echo -e "${BLUE} --------------------------------------------------${NC}"
fi
echo -e "All repositories processed! repositories: ${repo_num}  | succeed: $(( repo_num - fail_count )) | failed: ${fail_count}"

