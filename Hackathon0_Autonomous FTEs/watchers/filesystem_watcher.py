#!/usr/bin/env python3
"""
File System Watcher for AI Employee Vault
Monitors the Inbox folder and moves new files to Needs_Action for processing.
"""

import os
import sys
import time
import logging
import shutil
from pathlib import Path
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('FileSystemWatcher')


class FileSystemWatcher:
    """Watches the Inbox folder for new files and processes them."""
    
    def __init__(self, vault_path: str, check_interval: int = 10):
        self.vault_path = Path(vault_path)
        self.inbox = self.vault_path / 'Inbox'
        self.needs_action = self.vault_path / 'Needs_Action'
        self.logs_dir = self.vault_path / 'Logs'
        self.check_interval = check_interval
        self.processed_files = set()
        
        # Ensure directories exist
        self.inbox.mkdir(parents=True, exist_ok=True)
        self.needs_action.mkdir(parents=True, exist_ok=True)
        self.logs_dir.mkdir(parents=True, exist_ok=True)
        
    def check_for_new_files(self) -> list:
        """Check Inbox for new files that haven't been processed."""
        try:
            files = []
            for file_path in self.inbox.iterdir():
                if file_path.is_file() and file_path.suffix in ['.md', '.txt']:
                    if str(file_path) not in self.processed_files:
                        files.append(file_path)
            return files
        except Exception as e:
            logger.error(f"Error checking inbox: {e}")
            return []
    
    def create_action_file(self, source_file: Path) -> Path:
        """Move file from Inbox to Needs_Action with metadata."""
        try:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            dest_name = f"TASK_{timestamp}_{source_file.stem}.md"
            dest_path = self.needs_action / dest_name
            
            # Read original content
            content = source_file.read_text()
            
            # Add metadata header if not present
            if '---' not in content[:10]:
                metadata = f"""---
type: file_drop
source: Inbox
original_name: {source_file.name}
received: {datetime.now().isoformat()}
status: pending
---

"""
                content = metadata + content
            
            # Write to Needs_Action
            dest_path.write_text(content)
            
            # Move original file to Done as archive
            archive_path = self.vault_path / 'Done' / f"ARCHIVE_{timestamp}_{source_file.name}"
            shutil.copy2(source_file, archive_path)
            source_file.unlink()  # Remove from Inbox
            
            logger.info(f"Processed: {source_file.name} → {dest_name}")
            return dest_path
            
        except Exception as e:
            logger.error(f"Error processing {source_file}: {e}")
            return None
    
    def log_activity(self, action: str, details: str):
        """Log activity to the Logs folder."""
        try:
            log_file = self.logs_dir / f"watcher_{datetime.now().strftime('%Y-%m-%d')}.log"
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            with open(log_file, 'a') as f:
                f.write(f"[{timestamp}] {action}: {details}\n")
        except Exception as e:
            logger.error(f"Error logging activity: {e}")

    def update_dashboard(self):
        """Update Dashboard.md with current folder counts."""
        try:
            dashboard_path = self.vault_path / 'Dashboard.md'
            if not dashboard_path.exists():
                logger.warning("Dashboard.md not found")
                return

            # Count items in each folder
            inbox_count = len([f for f in self.inbox.iterdir() if f.is_file()])
            needs_action_count = len([f for f in self.needs_action.iterdir() if f.is_file()])
            done_count = len([f for f in (self.vault_path / 'Done').iterdir() if f.is_file()])
            active_count = len([f for f in (self.vault_path / 'Active_Project').iterdir() if f.is_file()])

            # Read current dashboard
            content = dashboard_path.read_text()
            
            import re

            # Update timestamp (handle various formats)
            timestamp = datetime.now().strftime('%Y-%m-%dT%H:%M:%S')
            content = re.sub(
                r'last_updated:.*',
                f'last_updated: {timestamp}',
                content
            )

            # Update Quick Stats
            content = self._update_stat(content, 'Items in Inbox', inbox_count)
            content = self._update_stat(content, 'Items Needing Action', needs_action_count)
            content = self._update_stat(content, 'Tasks Completed Today', done_count)
            content = self._update_stat(content, 'Active Projects', active_count)

            # Write updated dashboard
            dashboard_path.write_text(content)
            logger.info("Dashboard updated")
            self.log_activity("DASHBOARD_UPDATE", "Stats refreshed")

        except Exception as e:
            logger.error(f"Error updating dashboard: {e}")

    def _update_stat(self, content: str, stat_name: str, value: int) -> str:
        """Update a specific stat in the dashboard table."""
        import re
        # Pattern to match table row: | Stat Name | number |
        pattern = rf'(\|\s*{re.escape(stat_name)}\s*\|\s*)\d+'
        replacement = f'\\g<1>{value}'
        return re.sub(pattern, replacement, content)
    
    def run(self):
        """Main loop - continuously monitor Inbox."""
        logger.info(f"Starting FileSystemWatcher")
        logger.info(f"Watching: {self.inbox}")
        logger.info(f"Check interval: {self.check_interval}s")
        self.log_activity("WATCHER_START", f"Watching {self.inbox}")
        
        # Initial dashboard update
        self.update_dashboard()

        try:
            while True:
                new_files = self.check_for_new_files()

                for file_path in new_files:
                    dest_path = self.create_action_file(file_path)
                    if dest_path:
                        self.processed_files.add(str(file_path))
                        self.log_activity("FILE_PROCESSED", f"{file_path.name} → {dest_path.name}")
                        # Update dashboard after each file processed
                        self.update_dashboard()

                time.sleep(self.check_interval)
                
        except KeyboardInterrupt:
            logger.info("Watcher stopped by user")
            self.log_activity("WATCHER_STOP", "User interrupted")
        except Exception as e:
            logger.error(f"Watcher error: {e}")
            self.log_activity("WATCHER_ERROR", str(e))


def main():
    """Entry point for the watcher."""
    # Default vault path (can be overridden via environment variable)
    vault_path = os.environ.get(
        'VAULT_PATH',
        '/mnt/e/Q4-Hackathon/Hackathon0/h0-bronze-tier/AI_Employee_Vault'
    )
    
    check_interval = int(os.environ.get('CHECK_INTERVAL', '10'))
    
    watcher = FileSystemWatcher(vault_path, check_interval)
    watcher.run()


if __name__ == '__main__':
    main()
