# Bronze Tier - AI Employee Implementation

Complete implementation of the Bronze Tier requirements for the Personal AI Employee Hackathon.

## ✅ Completed Requirements

| Requirement | Status |
|-------------|--------|
| Obsidian vault with Dashboard.md | ✅ Complete |
| Company_Handbook.md with rules | ✅ Complete |
| Folder structure (/Inbox, /Needs_Action, /Done, /Active_Project, /Logs) | ✅ Complete |
| One working Watcher script | ✅ Complete (File System Watcher) |
| Qwen Code integration with vault | ✅ Complete (SKILL.md) |
| End-to-end testing | ✅ Verified |

## 📁 Project Structure

```
h0-bronze-tier/
├── AI_Employee_Vault/           # Obsidian vault
│   ├── Inbox/                   # Raw incoming items
│   ├── Needs_Action/            # Items requiring attention
│   ├── Active_Project/          # Currently in-progress work
│   ├── Done/                    # Completed tasks archive
│   ├── Logs/                    # Activity logs
│   ├── Dashboard.md             # Main dashboard
│   └── Company_Handbook.md      # Rules and guidelines
├── watchers/
│   └── filesystem_watcher.py    # File System Watcher script
├── scripts/
│   └── vault-ops.sh             # Vault operations helper
└── .qwen/skills/
    └── vault-processor/
        └── SKILL.md             # Qwen Code Agent Skill
```

## 🚀 Quick Start

### 1. Start the File System Watcher

```bash
# Start watching the Inbox folder
python3 watchers/filesystem_watcher.py
```

The watcher runs continuously, checking for new files every 10 seconds.

### 2. Process Inbox Items

```bash
# Manual processing (alternative to auto-watcher)
./scripts/vault-ops.sh process
```

### 3. Check Vault Status

```bash
./scripts/vault-ops.sh status
```

### 4. Update Dashboard

```bash
./scripts/vault-ops.sh update
```

## 📋 Vault Operations Commands

| Command | Description |
|---------|-------------|
| `./scripts/vault-ops.sh status` | Show vault status |
| `./scripts/vault-ops.sh process` | Process Inbox items |
| `./scripts/vault-ops.sh update` | Update Dashboard.md stats |
| `./scripts/vault-ops.sh log <action> <details>` | Log activity |
| `./scripts/vault-ops.sh help` | Show help |

## 🔄 Workflow

```
1. New file dropped in /Inbox
        ↓
2. File System Watcher detects (or manual process)
        ↓
3. File moved to /Needs_Action with metadata
        ↓
4. Qwen Code processes task (using vault-processor skill)
        ↓
5. Task moved to /Done when complete
        ↓
6. Dashboard.md updated
7. Activity logged in /Logs
```

## 📖 Company Handbook Rules

### Core Rules
1. **Always be polite** in all communications
2. **Flag payments over $500** for human approval
3. **Response time guidelines**:
   - Urgent: 15 minutes
   - High: 2 hours
   - Normal: 24 hours

### Approval Workflow
For sensitive actions (payments >$500):
1. Create file in `/Pending_Approval/`
2. Wait for human to move to `/Approved`
3. Execute action only after approval

## 🧪 E2E Test Results

```
✓ Test file created in /Inbox
✓ File System Watcher detected file
✓ File moved to /Needs_Action with metadata
✓ Dashboard.md updated (stats refreshed)
✓ Activity logged in /Logs/activity_2026-03-13.log
✓ Task moved to /Done (workflow complete)
```

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VAULT_PATH` | `/mnt/e/Q4-Hackathon/Hackathon0/h0-bronze-tier/AI_Employee_Vault` | Path to vault |
| `CHECK_INTERVAL` | `10` | Watcher check interval (seconds) |

### Example: Custom Configuration

```bash
export VAULT_PATH="/path/to/your/vault"
export CHECK_INTERVAL="30"
python3 watchers/filesystem_watcher.py
```

## 📝 Using Qwen Code

Qwen Code is configured with the `vault-processor` skill. To use:

1. Open Qwen Code in the project directory
2. Reference the skill: "Process the task in Needs_Action folder"
3. Qwen will use the vault-processor skill to:
   - Read task files
   - Execute required actions
   - Move files between folders
   - Update Dashboard.md
   - Log activities

## 📊 Dashboard Features

- **Pending Messages**: Track communications needing attention
- **Active Tasks**: View in-progress work items
- **Recent Activity**: Log of completed actions
- **Quick Stats**: Real-time folder counts
- **Alerts**: Important notifications

## 🛠️ Troubleshooting

### Watcher not detecting files
- Ensure watcher is running: `pgrep -f filesystem_watcher`
- Check file extensions: Only `.md` and `.txt` are processed
- Verify Inbox path is correct

### Dashboard not updating
- Run: `./scripts/vault-ops.sh update`
- Check file permissions on Dashboard.md

### Logs not appearing
- Verify Logs directory exists
- Check write permissions

## 📈 Next Steps (Silver Tier)

To advance to Silver Tier, add:
- [ ] Gmail Watcher script
- [ ] WhatsApp Watcher script
- [ ] MCP server for sending emails
- [ ] Human-in-the-loop approval workflow
- [ ] Scheduled tasks via cron

## 📄 License

Part of the Personal AI Employee Hackathon 0 - Bronze Tier
