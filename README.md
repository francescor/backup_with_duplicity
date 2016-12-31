# backup_with_duplicity
script to backup with duplicity



Simple script for creating backups with Duplicity.
(inspired by http://wiki.hetzner.de/index.php/Backup )

Full backups are made on the 1st day of each month or with the 'full' option.
Incremental backups are made on any other days.

 USAGE: backup_with_duplicity.sh [full]
