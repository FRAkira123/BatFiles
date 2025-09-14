:LOOP
rem check first argument whether it is empty and quit loop in case;
rem `%1` is the argument as is; `%~1` removes surrounding quotes;
rem `"%~1"` therefore ensures that the argument is always enclosed within quotes:
if "%~1"=="" goto :END
rem the argument is passed over to the command to execute (`"%~1"`):
magick.exe convert "%~1" -sampling-factor 4:2:0 -strip -quality 90 -interlace JPEG  "%~1.jpg"
rem `shift` makes the second argument (`%2`) to be the first (`%1`), the third (`%3`) to be the second (`%2`),...:
shift
rem go back to top:
goto :LOOP
:END
pause