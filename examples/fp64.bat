@echo off
if exist Win64 (rmdir /S /Q Win64)
mkdir Win64
ppcrossx64 %1.dpr -Fu"..\sources" -FU"Win64" -FE"..\bin"
pause