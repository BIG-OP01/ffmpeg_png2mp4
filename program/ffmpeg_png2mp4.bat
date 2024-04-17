@echo off
:: =========================================
:: 參數設置
set extenIn=png
set extenOut=mp4
set resolution=2560x1440
set setfps=120
:: extenIn        輸入檔的附檔名
:: extenOut     輸出檔的附檔名
:: resolution    輸出檔的解析度
:: setfps           輸出影片的fps
:: =========================================
:: 使用執行命令方式檢查系統中是否已安裝了 ffmpeg
echo 檢查 ffmpeg . . .
timeout /t 1 >nul
:: 執行 ffmpeg 版本訊息命令，並將標準錯誤輸出重新導向到標準輸出
ffmpeg -version >nul 2>&1

if %errorlevel% equ 0 (
	ffmpeg -version 2>&1 | findstr /C:"ffmpeg version"
	echo ffmpeg 已安裝在系統中。
) else (
    echo ffmpeg 未安裝在系統中。
	timeout /t 1 >nul
	echo.
	echo 請查閱 ffmpeg 安裝說明以了解如何安裝 ffmpeg。
	echo 下載網址：https://ffmpeg.org/download.html
	goto theEnd
)
timeout /t 2 >nul
cls
:: =========================================
:: 齒輪型別
choice /c:pg /n /m "請輸入齒輪型別 小齒輪/大齒輪(p/g):"
set choiceinput=%errorlevel%

if %choiceinput%==1 (
set geartype=pinion
set geartypes=p
)
if %choiceinput%==2 (
set geartype=gear
set geartypes=g
)
:: =========================================
:: 輸出方式
choice /c:ar /n /m "請輸入輸出方式 全部輸出/範圍輸出(a/r):"
set choiceinput=%errorlevel%

if %choiceinput%==1 (
set funoutput=all
goto inputframerate
)
if %choiceinput%==2 (
set funoutput=rang
goto inputnumber
)
:: =========================================
:: 設定圖片輸出範圍
:inputnumber
:: 圖片起始數字檢查
:inputstart_number
set /p "start_number=請輸入圖片起始數字："
if not defined start_number goto inputstart_number
:: 檢查輸入是否為純數字
echo %start_number%| findstr /R "^[0-9]*$" >nul
if errorlevel 1 (
    echo 請輸入有效的數字。
    goto inputstart_number
)
if %start_number% leq 0 (
	echo 請輸入大於0的數字。
    goto inputstart_number
)
:: 圖片結束數字檢查
:inputend_number
set /p "end_number=請輸入圖片結束數字："
if not defined end_number goto inputend_number
:: 檢查輸入是否為純數字
echo %end_number%| findstr /R "^[0-9]*$" >nul
if errorlevel 1 (
    echo 請輸入有效的數字。
    goto inputend_number
)
if %end_number% leq 0 (
	echo 請輸入大於0的數字。
    goto inputend_number
)
:: 圖片範圍檢查
set /a difference_number=end_number - start_number
if %difference_number% lss 0 (
	cls
	echo 圖片範圍不正確，請重新輸入。
    goto inputnumber
)
set /a difference_numberShow=difference_number + 1
echo 圖片範圍：%start_number% ~ %end_number% 、共%difference_numberShow%張。
:: =========================================
:: 設定每秒圖片張數
:inputframerate
set /p "framerate=請輸入每秒圖片張數: "
:: 檢查輸入是否為空
if not defined framerate  (
    set framerate=60
    echo 未輸入數字，將以預設值執行。^(預設：60^)
)
:: 檢查輸入是否為純數字
echo %framerate%| findstr /R "^[0-9]*$" >nul
if errorlevel 1 (
    echo 請輸入有效的數字。
    goto inputframerate
)
if %framerate% leq 0 (
	echo 請輸入大於0的數字。
    goto inputframerate
)
:: =========================================
:: 獲取當前時間 yyyyMMdd
for /f %%a in ('powershell -command "Get-Date -Format 'yyyyMMdd'"') do set mydatetime=%%a
set outputfile=%geartype%%mydatetime%
:: =========================================
:: ffmpeg合併

if %funoutput%==all (
ffmpeg -framerate %framerate% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% %outputfile%.%extenOut%
)
if %funoutput%==rang (
ffmpeg -framerate %framerate% -start_number %start_number% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% -vf "select=between(n\,0\,%difference_number%)" %outputfile%.%extenOut%
)

::ffmpeg -framerate %framerate% -start_number %start_number% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% -vf "select=between(n\,0\,%difference_number%)" %outputfile%.%extenOut%
::ffmpeg -framerate %framerate% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% -t 10 %outputfile%.%extenOut%
::ffmpeg -framerate %framerate% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% %outputfile%.%extenOut%

::-framerate n數      每秒n張圖
::-i 檔名.附檔名        輸入檔名格式
::-c:v h264_nvenc   解碼器
::-b:v 25M              位元速率//碼率 越高越清晰
::-r 120                   輸出影片的fps
::-s 2560x1440       輸出影片的解析度
::-t 10                     輸出影片的總時長

:: 檢查ffmpeg命令執行狀態
if %errorlevel% neq 0 (
    echo ffmpeg命令執行失敗。
	echo 請檢視上方日誌，並查閱 ffmpeg 相關說明。
	goto theEnd
)
:: =========================================
:: 獲取影片長度 HH:MM:SS.MICROSECONDS -> HHMMSS
for /f "tokens=1 delims=." %%t in ('ffprobe -v error -show_entries format^=duration -sexagesimal -of default^=noprint_wrappers^=1:nokey^=1 %outputfile%.%extenOut%') do set duration=%%t
set "duration=%duration::=%"
:: =========================================
:: 刪除重複檔案
if exist "%outputfile%_%duration%.%extenOut%" (
	goto overwrite
) else (
	goto notoverwrite
)
:overwrite
choice /t 5 /c:yn /d n /n /m "檔案已存在，是否覆蓋(y/n):"
set overinput=%errorlevel%
if %overinput%==1 (
	del /q "%outputfile%_%duration%.%extenOut%"
)
if %overinput%==2 (
	del /q "%outputfile%.%extenOut%"
	echo.
	echo 操作已取消。
	goto theEnd
)
:notoverwrite
:: =========================================
:: 重新命名檔案
ren "%outputfile%.%extenOut%" "%outputfile%_%duration%.%extenOut%"
:: =========================================
echo.
echo 檔案%outputfile%_%duration%.%extenOut%輸出完成
:theEnd
echo 請按任意鍵結束 . . .
pause >nul
exit /b


:: Author：WYC 2024/04/12