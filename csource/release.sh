#!/bin/bash
set -o errexit -o nounset -o pipefail
cd "`dirname $0`"

auth="Authorization: token ${GITHUB_TOKEN}"
accept="Accept: application/vnd.github.v3+json"

if ! curl --fail --location --silent --show-error --header "${auth}" --header "${accept}" https://api.github.com/repos/phronmophobic/membrane/releases/tags/${release} > release.json ; then
  echo "> Creating release ${release}"
  curl --fail --location --silent --show-error --header "${auth}" --header "${accept}" --request POST \
    --data "{\"tag_name\":\"${release}\",\"name\":\"${release}\"}" \
    https://api.github.com/repos/phronmophobic/membrane/releases > release.json
else
  echo "> Release ${release} exists"
  cat release.json
fi

[[ $(cat release.json | grep '"upload_url"') =~ https://.*/assets ]]
upload_url="${BASH_REMATCH[0]}?name=${artifact_name}"
rm release.json

echo "Uploading ${archive} to ${upload_url}"
# --header "Content-Type: application/zip" 
curl --fail --location --silent --show-error --header "${auth}" --header "${accept}" --request POST --data-binary "@${artifact_name}" ${upload_url}
