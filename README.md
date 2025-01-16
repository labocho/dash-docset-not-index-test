* ActiveRecord 7.0 と 7.1 で、7.1 だと Dash のインデックスが認識されない。
* diff は下記の通り

```
 % cmp -l ar7.0/test-ar7.0.docset/Contents/Resources/docSet.dsidx ar7.1/test-ar7.1.docset/Contents/Resources/docSet.dsidx                                                 2025-01-16T14:26:29
    19   1   2
    20   1   2
```

18,19 byte 目 (上記は 1-origin) が 1 なら OK、2 なら NG。
https://www.sqlite.org/fileformat.html によると

> 18	1	File format write version. 1 for legacy; 2 for WAL.
> 19	1	File format read version. 1 for legacy; 2 for WAL.

WAL は "Write-Ahead Log" で SQLite 3.7.0 移行で使われるモード (https://www.sqlite.org/wal.html)。

activerecord の diff をみてみる

```
$ git diff v7.0.8.7..v7.1.5.1 activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb
...
+            # Journal mode WAL allows for greater concurrency (many readers + one writer)
+            # https://www.sqlite.org/pragma.html#pragma_journal_mode
+            raw_execute("PRAGMA journal_mode = WAL", "SCHEMA")
...
```

https://github.com/rails/rails/blob/14c115b120ed089331ff3dc13f36bd9129ced33d/activerecord/lib/active_record/connection_adapters/sqlite3_adapter.rb#L733

このあたりで WAL を使うように設定している。
sqlite3 コマンドで `PRAGMA journal_mode;` で確認 `PRAGMA journal_mode=delete;` で WAL を使わないよう設定できる。

```
% sqlite3 ar7.1/test-ar7.1.docset/Contents/Resources/docSet.dsidx                                                                                                        2025-01-16T14:47:37
SQLite version 3.43.2 2023-10-10 13:08:14
Enter ".help" for usage hints.
sqlite> PRAGMA journal_mode;
wal
sqlite> PRAGMA journal_mode=delete;
delete
sqlite> .q
```
