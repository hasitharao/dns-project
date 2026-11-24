#!/usr/bin/env bash
# Prints every DNS and HTTP check used in the README, ready to screenshot.
# Usage: ./verify.sh yourname.dpdns.org
set -u

DOMAIN="${1:?Usage: ./verify.sh yourname.dpdns.org}"

heading() { printf '\n== %s ==\n' "$1"; }

lookup() {
  printf '$ dig %s\n' "$*"
  dig "$@" +noall +answer
}

status() {
  local code
  code=$(curl -s -o /dev/null -L -m 10 -w '%{http_code}' "$1")
  printf '%-48s HTTP %s\n' "$1" "${code:-000}"
}

heading "Nameservers (should be Cloudflare's)"
lookup "$DOMAIN" -t NS

heading "GitHub Pages: apex A and AAAA records"
lookup "$DOMAIN" -t A
lookup "$DOMAIN" -t AAAA

heading "GitHub Pages: www CNAME"
lookup "www.$DOMAIN" -t CNAME

heading "Self-hosted site: app subdomain (tunnel)"
lookup "app.$DOMAIN" -t CNAME
lookup "app.$DOMAIN" -t A

heading "Practice A record (placeholder IP)"
lookup "test.$DOMAIN" -t A

heading "Same answer from two public resolvers?"
lookup @1.1.1.1 "$DOMAIN" -t A
lookup @8.8.8.8 "$DOMAIN" -t A

heading "HTTP checks (final status after redirects)"
status "https://$DOMAIN"
status "https://www.$DOMAIN"
status "https://app.$DOMAIN"
