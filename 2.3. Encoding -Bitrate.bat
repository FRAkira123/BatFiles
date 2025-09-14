@echo off
:: Extract and display video information (resolution and frame rate)
ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -of default=nw=1 %1

:: Display the menu
echo.
echo Choose an encoding option:
echo 1. Discord (720p, 30fps, 128k audio, 10MB)
echo 2. DIY (Custom settings)
echo.

echo Select codec
set /p user_choice=Type option:

:: Set presets or switch to DIY mode
if "%user_choice%"=="1" goto DiscordEncoding

if "%user_choice%"=="2" goto DIYEncoding

:DiscordEncoding
set resX=1280
set fps=30
set audio=
set audiobitrate=128
set /p trimstart=Trim Start (sec): 
set /p trimend=Trim End (sec):
set sizewanted=9

:: Calculate the video bitrate
set /a videobitrate=((%sizewanted%*8388608)/(%trimend%-%trimstart%) - (%audiobitrate%*1000))/1000
echo Video Bitrate will be %videobitrate%k

:: Encode with H264
ffmpeg -y -ss %trimstart% -to %trimend% -i %1 -r %fps% -c:v h264_nvenc -b:v %videobitrate%k -maxrate %videobitrate%k -bufsize %videobitrate%k -vf "scale=%resX%:-1" -c:a libvorbis -b:a %audiobitrate%k %audio% -f mp4 %1_h264_%videobitrate%_%resX%.mp4
goto exit

::
::
::

:DIYEncoding
:: Mode DIY - Demander les paramètres à l'utilisateur
    set /p resX=Resolution (X): 
    set /p fps=Frame Rate (30 fps or your choice): 
    set /p audio=Audio (-an to disable): 
    set /p audiobitrate=Audio Bitrate (default 128): 
    if "%audio%"=="-an" (set audiobitrate=0)
    set /p trimstart=Trim Start (sec): 
    set /p trimend=Trim End (sec): 
    set /p sizewanted=Size Wanted (MB): 

:: Calculate video bitrate
set /a videobitrate=((%sizewanted%*8388608)/(%trimend%-%trimstart%) - (%audiobitrate%*1000))/1000
echo Video Bitrate will be %videobitrate%k

:: Encode with H264
ffmpeg -y -ss %trimstart% -to %trimend% -i %1 -r %fps% -c:v h264_nvenc -b:v %videobitrate%k -maxrate %videobitrate%k -bufsize %videobitrate%k -vf "scale=%resX%:-1" -c:a libvorbis -b:a %audiobitrate%k %audio% -f mp4 %1_h264_%videobitrate%_%resX%.mp4
goto exit

:exit
pause
exit