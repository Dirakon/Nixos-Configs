#!/usr/bin/env bash
# Based on this https://bluepie.in/2024/12/certbot-manual-hook/ !!!

# Certbot environment variables:
#  - CERTBOT_DOMAIN (the domain being authenticated)
#  - CERTBOT_VALIDATION (the validation string for TXT record)

PATH_TO_BEARER_TOKEN="/run/secrets/guide/dns/dns-api-token"
ROOT_DOMAIN="<<ROOT_DOMAIN>>"  # e.g., "domain.com"
DNS_RECORD_ID="<<DNS_RECORD_ID>>"
BEARER_TOKEN="$(cat "$PATH_TO_BEARER_TOKEN")"
TTL=600    
RECORD_NAME="_acme-challenge"

curl -X PATCH \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${BEARER_TOKEN}" \
  -d "{\"type\":\"TXT\",\"value\":\"${CERTBOT_VALIDATION}\",\"ttl\":${TTL}}" \
                          "https://api.timeweb.cloud/api/v2/domains/${RECORD_NAME}.${ROOT_DOMAIN}/dns-records/${DNS_RECORD_ID}"

echo "Timeweb AUTH-HOOK: Created TXT record for ${CERTBOT_DOMAIN}."

# Sleep to allow DNS propagation
sleep 60
