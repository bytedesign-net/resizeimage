#--- 設定 ----------------------------
$now = Get-Date #現在の日時
$date = Get-Date -Format yyyyMMddHHmmss #現在の日時の20230101010100形式
$dateTime = Get-Date -Format "yyyy-MM-dd-HHmms"　#今日の日付
$scriptDir = $PSScriptRoot #スクリプトのカレントディレクトリパス

ログファイルのパス
#$logFile = "C:\resizeimage\log\resizeimage_" + $date + ".log" #logファイルのパス
#-------------------------------------
#ログ出力スタート
#Start-Transcript $logFile -Force | Out-Null
#$scriptDir = $PSScriptRoot #スクリプトのカレントディレクトリパス

for ($input_Continue = "y"; $input_Continue -ne "n") { #終了を選択するまでループ
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $longSidesize = [Microsoft.VisualBasic.Interaction]::InputBox("長辺何pxまで縮小しますか?半角・整数値で入力してください", "ResizeImage")
    If ($longSidesize -eq '') {
            echo "キャンセルを選択しました"
            $wsobj.popup("キャンセルしました",0,"ResizeImage",0)
            exit       
    }
    $longSidesize = [int]$longSidesize
    #値が整数型でない場合
    if ($longSidesize -isnot [int]) {
        $wsobj = New-object -comobject wscript.shell
        $result = $wsobj.popup("整数値が正しく入力されていません。もう一度入力するには[OK]を押してください",0,"ResizeImage",1)
        if($result -eq "1"){
            echo "OKを選択しました"
            continue
        }
        else{
            echo "キャンセルを選択しました"
            $wsobj.popup("キャンセルしました",0,"ResizeImage",0)
            exit
        }
    }
    #値が整数型の場合
    else {
        break
    }
}

# 出力先のダイアログを表示
Add-Type -AssemblyName System.Windows.Forms
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ 
    RootFolder = "MyComputer"
    Description = 'リサイズした画像を保存するフォルダを選択してください'
}

if($FolderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK){
    #設定ファイルから出力するファイル形式を読み込み
    $dst = $FolderBrowser.SelectedPath + "`\"
    #バックアップの出力先のフォルダを作成
    $outputPath = $dst + "resizeimage_" + $dateTime
    New-Item $outputPath -ItemType Directory -Force
    #(ショートカットにドラッグで$imageExtensionsに受けわたす)
    foreach ($arg in $args) {
        $image = [System.Drawing.Image]::FromFile($arg)
        Add-Type -AssemblyName System.Drawing
        $filename = [System.IO.Path]::GetFileNameWithoutExtension($arg)
        $fileextention = [System.IO.Path]::GetExtension("$arg")
        $fileextention
        try {
            # 画像がタテ長(Portrait)であるかを判別する変数 isPortrait
            $isPortrait = $image.Height -gt $image.Width
            # 画像がタテ長、かつ横が800pxより大きい場合
            if ($isPortrait -and $image.Height -gt $longSidesize) {
                $ratio = $image.Width / $image.Height
                $newHeight = $longSidesize
                $newWidth = [int]($newHeight * $ratio)
            }
            # 画像がヨコ長、かつ縦が800pxより大きい場合
            elseif (-not $isPortrait -and $image.Width -gt $longSidesize) {
                $ratio = $image.Height / $image.Width
                $newWidth = $longSidesize
                $newHeight = [int]($newWidth * $ratio)
            }
            # 画像が正方形、かつ縦が800pxより大きい場合
            elseif ($image.Height -eq $image.Width -and $image.Height -gt $longSidesize) {
                $newWidth = $longSidesize
                $newHeight = $longSidesize
            }
            else {
                # 画像の長辺が800px未満でjpgファイルの場合、
                if ($fileextention -eq ".jpg") {
                    Copy-Item $arg -Destination $outputPath
                    continue
                }
                # 画像の長辺が800px未満でjpgファイル以外の場合
                else {
                    $newWidth = $image.Width
                    $newHeight = $image.Height
                }
            }

            #-------------------------------
            # 画像サイズを変更して保存
            #-------------------------------
            #$canvas = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
            $canvas = New-Object System.Drawing.Bitmap $newWidth, $newHeight
            if($canvas){
                $graphics = [System.Drawing.Graphics]::FromImage($canvas)
                $graphics.DrawImage($image, (New-Object System.Drawing.Rectangle(0, 0, $canvas.Width, $canvas.Height)))
                $image.Dispose()
                # Resizeデータの保存

                switch($fileextention) {
                    ".jpg" {
                        $canvas.Save($outputPath + "`\" + $filename + ".jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
                    }
                    ".jpeg" {
                        $canvas.Save($outputPath + "`\" + $filename + ".jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
                    }
                    ".png" {
                        $canvas.Save($outputPath + "`\" + $filename + ".png", [System.Drawing.Imaging.ImageFormat]::Png)
                    }
                    ".gif" {
                        $canvas.Save($outputPath + "`\" + $filename + ".gif", [System.Drawing.Imaging.ImageFormat]::Gif)
                    }
                    default {
                        $canvas.Save($outputPath + "`\" + $filename + ".jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)                        
                    }
                }
                $graphics.Dispose()
                $canvas.Dispose()
            }else{
                echo "変数 canvas が存在しません。"
            }
        }
        catch {
          Write-Host "Error occured.....";
          Write-Host $_ -BackgroundColor DarkRed;
          $tmp = Read-Host "Input 'y' to close this process......";
        }
        finally {
            $image.Dispose()
        }
    }
}
else {
    [System.Windows.MessageBox]::Show('フォルダは選択されませんでした')
}
#echo "ログ取得終了";
#Stop-Transcript | Out-Null #ログ取得終了
