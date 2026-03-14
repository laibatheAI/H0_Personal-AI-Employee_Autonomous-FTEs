#!/bin/bash
# Bronze Tier Verification Script
# Run this to verify all Bronze Tier requirements are complete

VAULT_PATH="${VAULT_PATH:-/mnt/e/Q4-Hackathon/Hackathon0/h0-bronze-tier/AI_Employee_Vault}"
PROJECT_ROOT="/mnt/e/Q4-Hackathon/Hackathon0/h0-bronze-tier"

echo "=============================================="
echo "  Bronze Tier Verification"
echo "=============================================="
echo ""

PASS=0
FAIL=0

check() {
    local name="$1"
    local condition="$2"
    
    if eval "$condition" > /dev/null 2>&1; then
        echo "✅ $name"
        ((PASS++))
    else
        echo "❌ $name"
        ((FAIL++))
    fi
}

echo "1. Vault Structure"
echo "-------------------"
check "Dashboard.md exists" "[ -f '$VAULT_PATH/Dashboard.md' ]"
check "Company_Handbook.md exists" "[ -f '$VAULT_PATH/Company_Handbook.md' ]"
check "/Inbox folder exists" "[ -d '$VAULT_PATH/Inbox' ]"
check "/Needs_Action folder exists" "[ -d '$VAULT_PATH/Needs_Action' ]"
check "/Done folder exists" "[ -d '$VAULT_PATH/Done' ]"
check "/Active_Project folder exists" "[ -d '$VAULT_PATH/Active_Project' ]"
check "/Logs folder exists" "[ -d '$VAULT_PATH/Logs' ]"
echo ""

echo "2. Watcher Script"
echo "-------------------"
check "File System Watcher exists" "[ -f '$PROJECT_ROOT/watchers/filesystem_watcher.py' ]"
check "Watcher is executable" "[ -x '$PROJECT_ROOT/watchers/filesystem_watcher.py' ]"
echo ""

echo "3. Qwen Code Integration"
echo "-------------------"
check "vault-processor SKILL.md exists" "[ -f '$PROJECT_ROOT/.qwen/skills/vault-processor/SKILL.md' ]"
check "skills-lock.json updated" "[ -f '$PROJECT_ROOT/skills-lock.json' ]"
check "vault-processor in skills-lock.json" "grep -q 'vault-processor' '$PROJECT_ROOT/skills-lock.json'"
echo ""

echo "4. Helper Scripts"
echo "-------------------"
check "vault-ops.sh exists" "[ -f '$PROJECT_ROOT/scripts/vault-ops.sh' ]"
check "vault-ops.sh is executable" "[ -x '$PROJECT_ROOT/scripts/vault-ops.sh' ]"
echo ""

echo "5. Dashboard Content"
echo "-------------------"
check "Dashboard has Pending Messages section" "grep -q 'Pending Messages' '$VAULT_PATH/Dashboard.md'"
check "Dashboard has Active Tasks section" "grep -q 'Active Tasks' '$VAULT_PATH/Dashboard.md'"
check "Dashboard has Recent Activity section" "grep -q 'Recent Activity' '$VAULT_PATH/Dashboard.md'"
echo ""

echo "6. Company Handbook Content"
echo "-------------------"
check "Handbook has politeness rule" "grep -q 'polite' '$VAULT_PATH/Company_Handbook.md'"
check "Handbook has \$500 approval rule" "grep -q '500' '$VAULT_PATH/Company_Handbook.md'"
check "Handbook has response time guidelines" "grep -q 'Response' '$VAULT_PATH/Company_Handbook.md'"
echo ""

echo "=============================================="
echo "  Results: $PASS passed, $FAIL failed"
echo "=============================================="

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "🎉 Bronze Tier Complete!"
    echo ""
    exit 0
else
    echo ""
    echo "⚠️  Some requirements missing. Review failed items above."
    echo ""
    exit 1
fi
