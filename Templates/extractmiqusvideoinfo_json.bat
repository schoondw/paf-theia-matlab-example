:: Batch file to extract information from Miqus video files.
:: Requires ffmpeg binaries on system path
:: Execute file root folder of project to extract video info from all files in project.
:: The output file is in json format, however, there is one empty miqusvideo element added since it was not trivial to remove the last comma.
@echo off
:: Define output file
set outfile=miqusvideoinfo_json.txt
:: Remove output file when it already exists
if exist %outfile% (
	del %outfile%
)
:: Create beginning of file (miqusvideo tag)
echo {"miqusvideo": [>> %outfile%
:: Append information for Miqus video files in current folder with subfolders
for /R %%i in (*Miqus*.avi) do (
	ffprobe -i "%%~fi" -v quiet -show_format -select_streams v:0 -show_streams -of json >> %outfile%
	echo ,>> %outfile%
)
:: Create end of file
echo {}]}>> %outfile%