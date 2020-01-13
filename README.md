# MVDL (Moodle Video Downloader)

This script will download vidoes from moodle recursively, by using Selenium to traverse the page.

The script uses Selenium to traverse the page, meaning you must have the Selenium module installed.

This can be done, by running the following command in a Powershell terminal:

```powershell
PS> Install-Module Selenium
```

## Known issues

If the user tabs out of the chrome session, the script is no longer able to save videos.

