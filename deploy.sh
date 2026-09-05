#!/usr/bin/env bash
set -euo pipefail

BLOG="${BLOG:-$HOME/blog}"
MSG="${1:-update}"

cd "$BLOG"

rm -rf public
hugo --minify

if [ -z "$(git status --porcelain)" ]; then
  echo "Rien a publier, aucun changement detecte."
  exit 0
fi

git status --short
git add -A
git commit -m "$MSG"
git push

echo "Attente du declenchement du workflow"
sleep 15
gh run watch "$(gh run list --workflow=hugo.yml --limit 1 --json databaseId --jq '.[0].databaseId')"

echo "Attente de la propagation"
sleep 45

for url in \
  "https://0xlhu.github.io/fr/" \
  "https://0xlhu.github.io/en/" \
  "https://0xlhu.github.io/fr/posts/malwaredna-resultat-negatif/" \
  "https://0xlhu.github.io/en/posts/malwaredna-negative-result/" \
  "https://0xlhu.github.io/fr/a-propos/" \
  "https://0xlhu.github.io/en/about/" \
  "https://0xlhu.github.io/fr/index.xml"
do
  printf '%-64s %s\n' "$url" "$(curl -sI "$url" | head -1 | tr -d '\r')"
done
