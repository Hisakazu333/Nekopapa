@echo off
REM OpenNeko Engine - Windows Build Script
REM Prerequisites: Qt 6, CMake, Visual Studio 2022

echo [1/4] Cleaning and creating build directory...
if exist build (
    echo Closing any running OpenNekoEngine processes...
    taskkill /f /im OpenNekoEngine.exe >nul 2>&1
    timeout /t 1 /nobreak >nul
    rd /s /q build
)
if not exist build mkdir build

echo [2/4] Configuring project with CMake...
cmake -B build -G "Visual Studio 17 2022" -A x64 -DNNA_ENABLE_LIVE2D=ON
if %errorlevel% neq 0 (
    echo [ERROR] CMake configuration failed! Please check if CMake and VS 2022 are installed.
    pause
    exit /b %errorlevel%
)

echo [3/4] Building project...
cmake --build build --config Release -j 8
if %errorlevel% neq 0 (
    echo [ERROR] Build failed! Please check the compiler errors above.
    pause
    exit /b %errorlevel%
)

echo [4/4] Deploying Qt dependencies...
REM Update the path to your Qt bin directory if necessary
if "%Qt6_DIR%"=="" (
    echo WARNING: Qt6_DIR not set. Please ensure windeployqt is in your PATH.
)
windeployqt --release --qmldir app/stage-desktop/qml build/app/stage-desktop/Release/OpenNekoEngine.exe

echo.
echo Build Complete!
echo Executable: build\app\stage-desktop\Release\OpenNekoEngine.exe
pause
