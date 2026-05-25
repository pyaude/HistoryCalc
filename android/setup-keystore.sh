#!/bin/bash
# ============================================================
# CI/CD Keystore Setup Script
# ============================================================
# Usage:
#   Source your keystore from environment variables (GitHub Secrets)
#   so the CI runner never stores the file in plain text.
#
# Required env vars:
#   KEYSTORE_BASE64  - base64-encoded .keystore file
#   KEYSTORE_PASSWORD
#   KEY_PASSWORD
#   KEY_ALIAS
# ============================================================

if [ -z "$KEYSTORE_BASE64" ]; then
  echo "ERROR: KEYSTORE_BASE64 not set. Cannot configure signing."
  exit 1
fi

echo "$KEYSTORE_BASE64" | base64 -d > android/self-upgrade.keystore

cat > android/key.properties <<EOF
storePassword=${KEYSTORE_PASSWORD:-pyaude123}
keyPassword=${KEY_PASSWORD:-pyaude123}
keyAlias=${KEY_ALIAS:-self-upgrade}
storeFile=self-upgrade.keystore
EOF

echo "Keystore configured successfully."
