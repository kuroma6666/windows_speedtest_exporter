# 初期設定
$BINDIR = "<SpeedtestCLIのディレクトリを指定する>"
$tempFile = "<SpeedtestCLIのディレクトリを指定する>\speedtest.prom"
$OUTDIR = "<promファイルの出力先>"
$SERVERID = "<SpeedetstのサーバーID>"

# コマンドの定義
$cmd = Join-Path -Path $BINDIR -ChildPath "speedtest.exe"

# コマンドの実行と結果取得
$results = & $cmd --accept-license --accept-gdpr -s $SERVERID -f csv

# 結果を処理
$results -split "`r`n" | ForEach-Object {
    if ($_ -ne "") {
        $fields = $_ -split ","

        # データのサニタイズ
        $latency = $fields[2] -replace '"', ''
        $jitter = $fields[3] -replace '"', ''
        $packetloss = $fields[4] -replace '"', ''
        $download = $fields[5] -replace '"', ''
        $upload = $fields[6] -replace '"', ''

        # データの出力
        @"
# HELP windows_speedtest_latency Latency (ms)
# TYPE windows_speedtest_latency
windows_speedtest_latency $latency
# HELP windows_speedtest_jitter Jitter (ms)
# TYPE windows_speedtest_jitter
windows_speedtest_jitter $jitter
# HELP windows_speedtest_packetloss Packet Loss (%)
# TYPE windows_speedtest_packetloss
windows_speedtest_packetloss $packetloss
# HELP windows_speedtest_download Download Speed (Bytes/sec)
# TYPE windows_speedtest_download
windows_speedtest_download $download
# HELP windows_speedtest_upload Upload Speed (Bytes/sec)
# TYPE windows_speedtest_upload
windows_speedtest_upload $upload
"@ | Out-File -FilePath $tempFile -Encoding utf8 -Append
    }
}

# 一時ファイルを正式ファイル名にリネーム
$finalFile = Join-Path $OUTDIR "speedtest.prom"
Move-Item -Path $tempFile -Destination $finalFile -Force
