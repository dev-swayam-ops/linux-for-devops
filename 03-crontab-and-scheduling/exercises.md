# Crontab and Scheduling: Exercises

Complete these exercises to master Linux job scheduling.

## Exercise 1: Basic Crontab Usage

**Tasks:**
1. View your current crontab
2. Edit crontab and add a comment explaining your user
3. List all cron jobs
4. Verify the entry was saved

**Example comment:**
```
# Crontab for training purposes
```

**Hint:** Use `crontab -l` and `crontab -e`.

---

## Exercise 2: Schedule a Daily Task

Create a script that prints current date and time, then schedule it to run daily.

**Tasks:**
1. Create script `daily_task.sh`:
   - Make it executable
   - Print: "Daily task executed at $(date)"
   - Redirect output to `daily_output.log`

2. Schedule to run every day at 3:00 PM
3. Verify crontab entry
4. Manually test the script

**Hint:** Cron format for 3:00 PM is `0 15 * * *`

---

## Exercise 3: Schedule Multiple Time Intervals

**Tasks:**
1. Schedule a task to run:
   - Every hour at minute 0
   - Every 6 hours
   - Every Monday at 9:00 AM
   - Every 1st of the month at midnight

2. Add these to crontab
3. List and verify all entries
4. Document what each line does

**Hint:** Use `*` for "any", `/` for intervals, specific numbers for exact times.

---

## Exercise 4: Handle Cron Output and Logging

Create a script that produces output and logs it properly.

**Tasks:**
1. Create script `backup_task.sh`:
   - Echo "Backup started"
   - Sleep 2 seconds
   - Echo "Backup completed"

2. Add to crontab with output redirection:
   - Stdout to `/tmp/backup_success.log`
   - Stderr to `/tmp/backup_error.log`

3. Run manually and verify logs
4. Check that both stdout and stderr are captured

**Hint:** Use `>` for stdout, `2>` for stderr, `2>&1` to combine them.

---

## Exercise 5: Create a Backup Schedule

**Tasks:**
1. Create `backup.sh` script that:
   - Creates a timestamped backup directory
   - Copies files from a test folder
   - Reports success/failure

2. Schedule daily at 2:00 AM
3. Include error handling in crontab entry
4. Add email notification on failure (or log it)

**Hint:** Use `mkdir -p backup_$(date +%Y%m%d_%H%M%S)`

---

## Exercise 6: Monitor Cron Job Execution

**Tasks:**
1. Add a test cron job that runs every minute
2. Check system logs to verify execution:
   - Using `journalctl` (if systemd)
   - Using `grep CRON /var/log/syslog`
3. Count how many times it ran in 5 minutes
4. Remove the test job after verification

**Hint:** Cron every minute: `* * * * * command`

---

## Exercise 7: Cron Job with Environment Variables

**Tasks:**
1. Create script that uses environment variables
2. Add to crontab with custom PATH and variables:
   ```
   PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
   MYVAR=myvalue
   0 1 * * * /path/to/script.sh
   ```

3. Verify script can access the variables
4. Test execution

**Hint:** Cron has limited PATH; always use full paths or set it.

---

## Exercise 8: Conditional Scheduling

**Tasks:**
1. Create script `conditional_task.sh` that:
   - Checks if a file exists
   - Runs different commands based on condition
   - Logs results

2. Schedule to run every 10 minutes
3. Test by creating and removing the test file
4. Verify logs show different outputs

**Hint:** Use `if [ -f /path/to/file ]` in your script.

---

## Exercise 9: System Resource Monitoring

**Tasks:**
1. Create script `monitor.sh` that:
   - Checks disk usage
   - Checks memory usage
   - Logs to file with timestamp

2. Schedule hourly
3. Run 3 times and collect output
4. Analyze the log file

**Hint:** Use `df`, `free`, and `date` commands in your script.

---

## Exercise 10: Manage Multiple Cron Jobs

**Tasks:**
1. Create 3 different scripts:
   - `cleanup.sh` - removes old files
   - `report.sh` - generates summary
   - `notify.sh` - sends notification

2. Schedule all three with different times
3. Export crontab to file: `crontab -l > my_crontab.txt`
4. Remove all jobs: `crontab -r`
5. Restore from file: `crontab my_crontab.txt`
6. Verify all jobs are restored

**Hint:** Use `crontab -l` and `crontab -r` for export/import.
