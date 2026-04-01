# 🧹 Tidy Bot: Automated Disk Cleanup Script

A robust Bash script designed for Senior Linux Systems Administrators to automate disk maintenance on Debian/Zorin and Archcraft/Arch systems.

[![ShellCheck: Passed](https://img.shields.io/badge/ShellCheck-Passed-brightgreen)](https://www.shellcheck.net/)

## 🚀 Features
- **Smart Threshold Check**: Only executes cleanup if the root partition usage exceeds a set percentage (default: 85%).
- **Cross-Distro Support**: Detects and uses `apt-get clean` or `pacman -Sc`.
- **Log Management**: Targets rotated logs (`.gz`, `.1`) older than 30 days in `/var/log`.
- **Temp Cleanup**: Removes files in `/tmp` not accessed in over 7 days.
- **Docker Pruning**: Integrated `docker system prune -f` if Docker is present.
- **Safety First**: Optional `DRY_RUN` mode to preview deletions.
- **Auditing**: Logs all actions with timestamps to `/var/log/tidy_bot.log`.

---

## 🛠️ Setup Instructions

### 1. Installation
1. Download or create the script:
   ```bash
   sudo touch /usr/local/bin/tidy_bot.sh
   ```
2. Paste the script content into the file and make it executable:
   ```bash
   sudo chmod +x /usr/local/bin/tidy_bot.sh
   ```

### 2. Manual Execution (Test Mode)
Before automating, run a dry run to see exactly what would be removed:
```bash
sudo DRY_RUN=true /usr/local/bin/tidy_bot.sh
```

---

## ⏰ Automation with Cron

To set this script to run automatically every night at midnight, follow these steps:

1. Open the root user's crontab:
   ```bash
   sudo crontab -e
   ```

2. Add the following line to the end of the file:
   ```cron
   0 0 * * * /usr/local/bin/tidy_bot.sh >> /var/log/tidy_bot_cron.log 2>&1
   ```

### Cron Explained:
- `0 0 * * *`: Runs at **00:00 (Midnight)** every day.
- `/usr/local/bin/tidy_bot.sh`: The path to your script.
- `>> /var/log/tidy_bot_cron.log 2>&1`: Captures any errors or output for further debugging.

---

## ⚙️ Configuration
You can override the defaults without editing the script by setting environment variables in the crontab or shell:

```bash
# Example: Cleanup if usage is over 70% instead of 85%
sudo THRESHOLD=70 /usr/local/bin/tidy_bot.sh
```

## 📜 Logs
Monitor your cleanup history anytime:
```bash
tail -f /var/log/tidy_bot.log
```
