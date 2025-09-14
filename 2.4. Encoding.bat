echo off
:begin

ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of default=nw=1 %1

echo Select basic settings
set /p resX=Resolution(keep format by X): 
set /p audio=Audio(type "-an" turn off): 
set /p audiobitrate=Audio Bitrate( base 128 ):

echo Select option
echo 1) NOTRIM
echo 2) TRIM
set /p choicetrim=Type option:
if "%choicetrim%"=="1" goto :selectcodecnotrim
if "%choicetrim%"=="2" goto :trim


:selectcodecnotrim
echo Select codec
echo 1) Option 1 VP8
echo 2) Option 2 VP9
echo 3) Option 3 AV1
echo 4) Option 4 H264
echo 5) Option 5 H265
set /p choicecodec=Type option:
if "%choicecodec%"=="1" goto vp8notrim
if "%choicecodec%"=="2" goto vp9notrim
if "%choicecodec%"=="3" goto av1notrim
if "%choicecodec%"=="4" goto h264notrim
if "%choicecodec%"=="5" goto h265notrim



:vp8notrim
set /p qp=Global Quality(best-- base 10 -- worse): 
ffmpeg -y -i %1 -quality realtime -speed 5 -threads 8 -row-mt 1 -tile-columns 2 -frame-parallel 1 -c:v libvpx -qmin 4 -qmax 40 -b:v 2M -crf %qp% -r 30 -c:a libvorbis -b:a %audiobitrate%k %audio% -vf "scale=%resX%:-1" %1_vp8_%qp%_%resX%.webm
goto exit

:vp9notrim
set /p qp=Global Quality(best - base 35 - worse): 
ffmpeg -y -i %1 -quality realtime -speed 5 -threads 8 -row-mt 1 -tile-columns 2 -frame-parallel 1 -c:v libvpx-vp9 -qmin 4 -qmax 40 -b:v 2M -crf %qp% -b:v 0 -r 30 -c:a libvorbis -b:a %audiobitrate%k %audio% -vf "scale=%resX%:-1" %1_vp9_%qp%_%resX%.webm
goto exit

:av1notrim
set /p qp=Global Quality(best-- base 30 -- worse): 
ffmpeg -y -i %1 -c:v libsvtav1 -r 30 -svtav1-params tune=0:enable-overlays=1:scd=1:preset=9:crf=%qp%:keyint=-1 -c:a libvorbis -b:a %audiobitrate%k %audio% -vf "scale=%resX%:-1" %1_av1_%qp%_%resX%.mp4
goto exit

:h264notrim
set /p qp=Global Quality( best - base 23 - worse): 
ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -i %1 -r 30 -c:v h264_nvenc -preset p5 -rc constqp -qp %qp% -vf "scale_cuda=%resX%:-1" -c:a libvorbis -b:a %audiobitrate%k %audio% -f mp4 %1_h264_nvenc_%qp%_trim_%resX%.mp4
goto exit

:h265notrim
set /p qp=Global Quality( best - base 28 - worse): 
ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -i %1 -r 30 -c:v hevc_nvenc -preset p5 -rc constqp -qp %qp% -vf "scale_cuda=%resX%:-1" -c:a libvorbis -b:a %audiobitrate%k %audio% %1_hevc_nvenc_%qp%_%resX%.mp4
goto exit



:trim
set /p trimstart=Trim Start( second ): 
set /p trimend=Trim End( second ): 
goto selectcodectrim

:selectcodectrim
echo Select codec
echo 1) Option 1 VP8
echo 2) Option 2 VP9
echo 3) Option 3 AV1
echo 4) Option 4 H264
echo 5) Option 5 H265
set /p choicecodec=Type option:
if "%choicecodec%"=="1" goto vp8rim
if "%choicecodec%"=="2" goto vp9rim
if "%choicecodec%"=="3" goto av1rim
if "%choicecodec%"=="4" goto h264rim
if "%choicecodec%"=="5" goto h265rim




:vp8rim
set /p qp=Global Quality(best-- base 10 -- worse): 
ffmpeg -y -ss %trimstart% -to %trimend% -i %1 -quality realtime -speed 5 -threads 8 -row-mt 1 -tile-columns 2 -frame-parallel 1 -c:v libvpx -qmin 4 -qmax 40 -b:v 2M -crf %qp% -r 30 -c:a libvorbis -b:a %audiobitrate%k %audio% -vf "scale=%resX%:-1" %1_vp8_%qp%_trim_%resX%.webm
goto exit

:vp9rim
set /p qp=Global Quality(best - base 35 - worse): 
ffmpeg -y -ss %trimstart% -to %trimend% -i %1 -quality realtime -speed 5 -threads 8 -row-mt 1 -tile-columns 2 -frame-parallel 1 -c:v libvpx-vp9 -qmin 4 -qmax 40 -b:v 2M -crf %qp% -b:v 0 -r 30 -c:a libvorbis -b:a %audiobitrate%k %audio% -vf "scale=%resX%:-1" %1_vp9_%qp%_%resX%.webm
goto exit

:av1rim
set /p qp=Global Quality(best-- base 30 -- worse): 
ffmpeg -y -ss %trimstart% -to %trimend% -i %1 -c:v libsvtav1 -r 30 -svtav1-params tune=0:enable-overlays=1:scd=1:preset=9:crf=%qp%:keyint=-1 -c:a libvorbis -b:a %audiobitrate%k -vf "scale=%resX%:-1" %1_av1_%qp%_trim_%resX%.mp4
goto exit

:h264rim
set /p qp=Global Quality( best - base 23 - worse): 
ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -ss %trimstart% -to %trimend% -i %1 -r 30 -c:v h264_nvenc -preset p5 -rc constqp -qp %qp% -vf "scale_cuda=%resX%:-1" -c:a libvorbis -b:a %audiobitrate%k %audio% -f mp4 %1_h264_nvenc_%qp%_trim_%resX%.mp4
goto exit

:h265rim
set /p qp=Global Quality( best - base 28 - worse):
ffmpeg -y -hwaccel cuda -hwaccel_output_format cuda -ss %trimstart% -to %trimend% -i %1 -r 30 -c:v hevc_nvenc -preset p5 -rc constqp -qp %qp% -vf "scale_cuda=%resX%:-1" -c:a libvorbis -b:a %audiobitrate%k %audio% %1_hevc_nvenc_%qp%_%resX%.mp4
goto exit



:exit
pause
@exit