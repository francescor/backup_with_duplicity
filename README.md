# backup_with_duplicity
script to backup with duplicity



Simple script for creating backups with Duplicity.
(inspired by http://wiki.hetzner.de/index.php/Backup )

Full backups are made on the 1st day of each month or with the 'full' option.
Incremental backups are made on any other days.

Usage:

`
backup_with_duplicity.sh [full]
`

Cronjob

`
# backup with duplicity
28 13 * * * /backup_with_duplicity.sh 
`
