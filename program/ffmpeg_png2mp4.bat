@echo off
:: =========================================
:: �ѼƳ]�m
set extenIn=png
set extenOut=mp4
set resolution=2560x1440
set setfps=120
:: extenIn        ��J�ɪ����ɦW
:: extenOut     ��X�ɪ����ɦW
:: resolution    ��X�ɪ��ѪR��
:: setfps           ��X�v����fps
:: =========================================
:: �ϥΰ���R�O�覡�ˬd�t�Τ��O�_�w�w�ˤF ffmpeg
echo �ˬd ffmpeg . . .
timeout /t 1 >nul
:: ���� ffmpeg �����T���R�O�A�ñN�зǿ��~��X���s�ɦV��зǿ�X
ffmpeg -version >nul 2>&1

if %errorlevel% equ 0 (
	ffmpeg -version 2>&1 | findstr /C:"ffmpeg version"
	echo ffmpeg �w�w�˦b�t�Τ��C
) else (
    echo ffmpeg ���w�˦b�t�Τ��C
	timeout /t 1 >nul
	echo.
	echo �Ьd�\ ffmpeg �w�˻����H�F�Ѧp��w�� ffmpeg�C
	echo �U�����}�Ghttps://ffmpeg.org/download.html
	goto theEnd
)
timeout /t 2 >nul
cls
:: =========================================
:: �������O
choice /c:pg /n /m "�п�J�������O �p����/�j����(p/g):"
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
:: ��X�覡
choice /c:ar /n /m "�п�J��X�覡 ������X/�d���X(a/r):"
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
:: �]�w�Ϥ���X�d��
:inputnumber
:: �Ϥ��_�l�Ʀr�ˬd
:inputstart_number
set /p "start_number=�п�J�Ϥ��_�l�Ʀr�G"
if not defined start_number goto inputstart_number
:: �ˬd��J�O�_���¼Ʀr
echo %start_number%| findstr /R "^[0-9]*$" >nul
if errorlevel 1 (
    echo �п�J���Ī��Ʀr�C
    goto inputstart_number
)
if %start_number% leq 0 (
	echo �п�J�j��0���Ʀr�C
    goto inputstart_number
)
:: �Ϥ������Ʀr�ˬd
:inputend_number
set /p "end_number=�п�J�Ϥ������Ʀr�G"
if not defined end_number goto inputend_number
:: �ˬd��J�O�_���¼Ʀr
echo %end_number%| findstr /R "^[0-9]*$" >nul
if errorlevel 1 (
    echo �п�J���Ī��Ʀr�C
    goto inputend_number
)
if %end_number% leq 0 (
	echo �п�J�j��0���Ʀr�C
    goto inputend_number
)
:: �Ϥ��d���ˬd
set /a difference_number=end_number - start_number
if %difference_number% lss 0 (
	cls
	echo �Ϥ��d�򤣥��T�A�Э��s��J�C
    goto inputnumber
)
set /a difference_numberShow=difference_number + 1
echo �Ϥ��d��G%start_number% ~ %end_number% �B�@%difference_numberShow%�i�C
:: =========================================
:: �]�w�C��Ϥ��i��
:inputframerate
set /p "framerate=�п�J�C��Ϥ��i��: "
:: �ˬd��J�O�_����
if not defined framerate  (
    set framerate=60
    echo ����J�Ʀr�A�N�H�w�]�Ȱ���C^(�w�]�G60^)
)
:: �ˬd��J�O�_���¼Ʀr
echo %framerate%| findstr /R "^[0-9]*$" >nul
if errorlevel 1 (
    echo �п�J���Ī��Ʀr�C
    goto inputframerate
)
if %framerate% leq 0 (
	echo �п�J�j��0���Ʀr�C
    goto inputframerate
)
:: =========================================
:: �����e�ɶ� yyyyMMdd
for /f %%a in ('powershell -command "Get-Date -Format 'yyyyMMdd'"') do set mydatetime=%%a
set outputfile=%geartype%%mydatetime%
:: =========================================
:: ffmpeg�X��

if %funoutput%==all (
ffmpeg -framerate %framerate% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% %outputfile%.%extenOut%
)
if %funoutput%==rang (
ffmpeg -framerate %framerate% -start_number %start_number% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% -vf "select=between(n\,0\,%difference_number%)" %outputfile%.%extenOut%
)

::ffmpeg -framerate %framerate% -start_number %start_number% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% -vf "select=between(n\,0\,%difference_number%)" %outputfile%.%extenOut%
::ffmpeg -framerate %framerate% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% -t 10 %outputfile%.%extenOut%
::ffmpeg -framerate %framerate% -i %geartypes%%%05d.%extenIn% -c:v h264_nvenc -b:v 25M -preset slow -r %setfps% -s %resolution% %outputfile%.%extenOut%

::-framerate n��      �C��n�i��
::-i �ɦW.���ɦW        ��J�ɦW�榡
::-c:v h264_nvenc   �ѽX��
::-b:v 25M              �줸�t�v//�X�v �V���V�M��
::-r 120                   ��X�v����fps
::-s 2560x1440       ��X�v�����ѪR��
::-t 10                     ��X�v�����`�ɪ�

:: �ˬdffmpeg�R�O���檬�A
if %errorlevel% neq 0 (
    echo ffmpeg�R�O���楢�ѡC
	echo ���˵��W���x�A�ìd�\ ffmpeg ���������C
	goto theEnd
)
:: =========================================
:: ����v������ HH:MM:SS.MICROSECONDS -> HHMMSS
for /f "tokens=1 delims=." %%t in ('ffprobe -v error -show_entries format^=duration -sexagesimal -of default^=noprint_wrappers^=1:nokey^=1 %outputfile%.%extenOut%') do set duration=%%t
set "duration=%duration::=%"
:: =========================================
:: �R�������ɮ�
if exist "%outputfile%_%duration%.%extenOut%" (
	goto overwrite
) else (
	goto notoverwrite
)
:overwrite
choice /t 5 /c:yn /d n /n /m "�ɮפw�s�b�A�O�_�л\(y/n):"
set overinput=%errorlevel%
if %overinput%==1 (
	del /q "%outputfile%_%duration%.%extenOut%"
)
if %overinput%==2 (
	del /q "%outputfile%.%extenOut%"
	echo.
	echo �ާ@�w�����C
	goto theEnd
)
:notoverwrite
:: =========================================
:: ���s�R�W�ɮ�
ren "%outputfile%.%extenOut%" "%outputfile%_%duration%.%extenOut%"
:: =========================================
echo.
echo �ɮ�%outputfile%_%duration%.%extenOut%��X����
:theEnd
echo �Ы����N�䵲�� . . .
pause >nul
exit /b


:: Author�GWYC 2024/04/12