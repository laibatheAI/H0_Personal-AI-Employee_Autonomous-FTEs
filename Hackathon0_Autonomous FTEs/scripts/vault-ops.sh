#!/bin/bash
# Vault Operations Helper Script
# Usage: ./vault-ops.sh <command> [args]

VAULT_PATH="${VAULT_PATH:-/mnt/e/Q4-Hackathon/Hackathon0/h0-bronze-tier/AI_Employee_Vault}"
LOGS_DIR="$VAULT_PATH/Logs"

log_activity() {
    local action="$1"
    local details="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOGS_DIR/activity_$(date +%Y-%m-%d).log"
    echo "[$timestamp] $action: $details" >> "$log_file"
    echo "✓ Logged: $action"
}

count_items() {
    local folder="$1"
    ls -1 "$VAULT_PATH/$folder" 2>/dev/null | wc -l
}

update_dashboard() {
    local inbox_count=$(count_items "Inbox")
    local needs_action_count=$(count_items "Needs_Action")
    local done_count=$(count_items "Done")
    local active_count=$(count_items "Active_Project")
    local timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')
    
    # Update the last_updated field in Dashboard.md
    sed -i "s/last_updated: .*/last_updated: $timestamp/" "$VAULT_PATH/Dashboard.md"
    
    # Update Quick Stats (simple approach - updates the numbers)
    sed -i "s/Items in Inbox | .*/Items in Inbox | $inbox_count/" "$VAULT_PATH/Dashboard.md"
    sed -i "s/Items Needing Action | .*/Items Needing Action | $needs_action_count/" "$VAULT_PATH/Dashboard.md"
    sed -i "s/Tasks Completed Today | .*/Tasks Completed Today | $done_count/" "$VAULT_PATH/Dashboard.md"
    sed -i "s/Active Projects | .*/Active Projects | $active_count/" "$VAULT_PATH/Dashboard.md"
    
    echo "✓ Dashboard updated"
    log_activity "DASHBOARD_UPDATE" "Stats refreshed"
}

add_to_recent() {
    local action="$1"
    local category="$2"
    local result="$3"
    local date=$(date '+%Y-%m-%d')
    
    # Add entry to Recent Activity table in Dashboard.md
    # This is a simplified version - full implementation would parse markdown table
    echo "  - [$date] $action ($category): $result" >> "$VAULT_PATH/Logs/recent_activity.md"
    echo "✓ Added to recent activity"
}

show_status() {
    echo "=== AI Employee Vault Status ==="
    echo "Vault Path: $VAULT_PATH"
    echo ""
    echo "Folder Contents:"
    echo "  Inbox:        $(count_items 'Inbox') items"
    echo "  Needs_Action: $(count_items 'Needs_Action') items"
    echo "  Active_Project: $(count_items 'Active_Project') items"
    echo "  Done:         $(count_items 'Done') items"
    echo ""
    echo "Recent Logs:"
    ls -la "$LOGS_DIR"/*.log 2>/dev/null | tail -3
}

process_inbox() {
    echo "Processing Inbox..."
    for file in "$VAULT_PATH/Inbox"/*.md "$VAULT_PATH/Inbox"/*.txt; do
        [ -f "$file" ] || continue
        filename=$(basename "$file")
        timestamp=$(date '+%Y%m%d_%H%M%S')
        dest_name="TASK_${timestamp}_${filename%.*}.md"
        
        # Add metadata and move to Needs_Action
        {
            echo "---"
            echo "type: file_drop"
            echo "source: Inbox"
            echo "original_name: $filename"
            echo "received: $(date -Iseconds)"
            echo "status: pending"
            echo "---"
            echo ""
            cat "$file"
        } > "$VAULT_PATH/Needs_Action/$dest_name"
        
        # Archive original
        cp "$file" "$VAULT_PATH/Done/ARCHIVE_${timestamp}_${filename}"
        rm "$file"
        
        echo "  ✓ Processed: $filename → $dest_name"
        log_activity "INBOX_PROCESSED" "$filename"
    done
    
    update_dashboard
}

# Main command handler
case "${1:-help}" in
    status)
        show_status
        ;;
    update)
        update_dashboard
        ;;
    process)
        process_inbox
        ;;
    log)
        log_activity "${2:-MANUAL}" "${3:-User initiated}"
        ;;
    add-activity)
        add_to_recent "$2" "$3" "$4"
        ;;
    help|*)
        echo "Vault Operations Helper"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  status              Show vault status"
        echo "  update              Update Dashboard.md stats"
        echo "  process             Process Inbox items"
        echo "  log <action> <details>  Log activity"
        echo "  add-activity <action> <category> <result>  Add to recent activity"
        echo "  help                Show this help"
        ;;
esac
