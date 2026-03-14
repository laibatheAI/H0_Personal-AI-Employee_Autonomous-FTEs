---
name: vault-processor
description: |
  Process items in the AI Employee Vault. Move tasks between folders,
  update Dashboard.md, log activities, and manage the task workflow.
  Use when tasks require processing Inbox items, moving files between
  vault folders, or updating the dashboard.
---

# AI Employee Vault Processor

Process and manage tasks in the Obsidian vault using Qwen Code.

## Folder Structure

```
AI_Employee_Vault/
├── Inbox/           # Raw incoming items (auto-processed by watcher)
├── Needs_Action/    # Items requiring attention
├── Active_Project/  # Currently in-progress work
├── Done/            # Completed tasks archive
├── Logs/            # Activity logs
├── Dashboard.md     # Main dashboard
└── Company_Handbook.md  # Rules and guidelines
```

## Workflow

### 1. Process Needs_Action Items

```bash
# List all items needing action
ls Needs_Action/

# Read an item to understand what needs to be done
cat Needs_Action/TASK_*.md

# After processing, move to Done
mv Needs_Action/TASK_*.md Done/
```

### 2. Update Dashboard

When processing tasks, update `Dashboard.md`:
- Add completed items to "Recent Activity" section
- Update "Active Tasks" with current work
- Update "Quick Stats" counts

### 3. Log Activity

Create/update log file in `/Logs`:
```bash
echo "[$(date '+%Y-%m-%d %H:%M:%S')] TASK_COMPLETE: Processed TASK_*.md" >> Logs/activity.log
```

## Rules (from Company_Handbook)

1. **Always be polite** in all communications
2. **Flag payments over $500** for human approval
3. **Response times**: Urgent (15min), High (2hr), Normal (24hr)
4. **Never share sensitive information** without encryption

## Task States

| State | Folder | Description |
|-------|--------|-------------|
| New | /Inbox | Unprocessed incoming items |
| Pending | /Needs_Action | Awaiting processing |
| In Progress | /Active_Project | Currently being worked on |
| Complete | /Done | Finished tasks |

## Qwen Code Commands

### Read and Process Task
```bash
# Read task
cat Needs_Action/TASK_*.md

# Determine action needed based on content
# Execute required actions
# Move to Done when complete
```

### Update Dashboard
```bash
# Count items in each folder
inbox_count=$(ls -1 Inbox/ 2>/dev/null | wc -l)
needs_action_count=$(ls -1 Needs_Action/ 2>/dev/null | wc -l)
done_count=$(ls -1 Done/ 2>/dev/null | wc -l)

# Update Dashboard.md with new counts
```

### Log Activity
```bash
echo "[$(date -Iseconds)] ACTION: Description" >> Logs/activity_$(date +%Y-%m-%d).log
```

## Example: Process Email Task

1. Read task file from `Needs_Action/`
2. Extract: sender, subject, priority, requested action
3. Draft response (if needed)
4. Execute action (or create approval request if >$500)
5. Move task to `Done/`
6. Update `Dashboard.md`
7. Log activity

## Approval Workflow

For sensitive actions (payments >$500, etc.):

1. Create file: `Pending_Approval/APPROVAL_{Type}_{Description}.md`
2. Include all details and required decision
3. **Wait** for human to move to `/Approved` folder
4. Only then execute the action

## Error Handling

- If task cannot be completed, move to `Needs_Action/RETRY_*.md`
- Log error details in `/Logs/error_*.log`
- Escalate to human if retry count > 3
