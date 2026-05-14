#!/system/bin/sh
# ===========================================
# dnscrypt-proxy 2 for Android - Revived - service.sh
# ===========================================
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed. Ensures module works even if
# Magisk changes its mount point in the future.
# ===========================================
MODDIR=${0%/*}

BIN="$MODDIR/system/bin/dnscrypt-proxy"
CONF="/data/adb/dnscrypt-proxy/dnscrypt-proxy.toml"

# ------------------------------
# Auto-Update OISD Blocklists (Background)
# ------------------------------
(
    # Wait for an active internet connection
    while ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; do
        sleep 10
    done

    TARGET_FILE="/data/adb/dnscrypt-proxy/blocked-names.txt"

    # Pull both OISD domainsets, merge, remove duplicates, and output to target
    {
        curl -sL https://big.oisd.nl/domainswild
        curl -sL https://nsfw.oisd.nl/domainswild
    } | sort -u > "$TARGET_FILE"
    
) &

# ------------------------------
# Run dnscrypt-proxy until it starts successfully
# ------------------------------
while ! pgrep -x dnscrypt-proxy >/dev/null 2>&1; do
    "$BIN" -config "$CONF" && sleep 15
done
