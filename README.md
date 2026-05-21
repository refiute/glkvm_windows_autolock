# glkvm_windows_autolock

GLKVM (PiKVM 互換 remote KVM) を介して、接続中の Windows マシンに毎日 21:55 (GLKVM のローカル時刻) で **Win + L (ロック)** を送る cron セットアップ。

## 動作環境

- GLKVM 本体上の Linux (python3 + cron + root pip 利用可)
- GLKVM のローカル時刻が目的のタイムゾーン (JST) に設定済み

## セットアップ

```sh
git clone <this-repo>
cd glkvm_windows_autolock
make install        # pip install + パスワードプロンプト + cron 登録
```

`make install` 実行時に GLKVM (PiKVM) の admin パスワードを入力します (エコー無し、`.env` に mode 0600 で保存)。

## 動作確認

```sh
make test           # 接続中の Windows が即座にロックされます
```

成功すると標準出力に `Sent Win+L successfully` が出力されます。cron 経由で実行された場合は `autolock.log` に追記されます。

## アンインストール

```sh
make uninstall      # cron エントリと .env を削除
```

`pikvm-lib` は他用途で使っている可能性があるため自動アンインストールしません。必要なら `pip3 uninstall -y pikvm-lib` を手動で。

## 仕組み

- `lock_windows.py` … `.env` から `GLKVM_PASSWORD` を読み、`pikvm_lib.PiKVM(hostname="localhost", username="admin", password=...).hotkey("win", "l")` を呼ぶ。
- `Makefile` … `crontab -l` を `# glkvm-autolock` タグで冪等に書き換え、`55 21 * * *` で `lock_windows.py` を実行する行を登録する。
