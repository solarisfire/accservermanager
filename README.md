# accservermanager Discord Link
Bash solution to watch the ACC server manager results folder and post to discord when new results drop in. Very much a WIP.

Pre-requisites will be:

* ACC Server running on Linux in Wine
* ACC Server Manager setup correctly - https://github.com/gotzl/accservermanager
* A Discord server, with a channel, and a webhook link.
* Discord.sh - https://chaoticweg.cc/discord.sh/
* inotifywait - https://linux.die.net/man/1/inotifywait
* JQ - https://stedolan.github.io/jq/
* BC & DC - Needed to convert miliseconds to human readable.

Instructions

* Modify the results_dir variable to point the the results directory
* Modify the WEBHOOK variable with a valid discord webhook link
* Run
