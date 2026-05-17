#Requires AutoHotkey v2.0

keepass_path :=  "G:\My Drive\KeePass Database.kdbx"
date := Format("{}-{}-{}", A_YYYY, A_MM, A_DD)
backup_path := StrReplace(keepass_path, ".", format(" {}.", date))

alt_backup_path := "G:\My Drive\Backups\KeePass\KeePass Database.kbdx"
alt_backup_path := StrReplace(alt_backup_path, ".", format(" {}.", date))

FileCopy(keepass_path, backup_path, true)
FileCopy(keepass_path, alt_backup_path, true)

message := format("Copied {} to {}.", keepass_path, backup_path)
message .= "`n"
message .= format("Copied {} to {}.", keepass_path, alt_backup_path)

MsgBox(message)

Run("G:\My Drive")

