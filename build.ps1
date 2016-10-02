Add-Type -AssemblyName System.IO.Compression.FileSystem

$V8VERSION = "4.9.385.33"
$BUILD = "1"

wget https://storage.googleapis.com/chrome-infra/depot_tools.zip -OutFile $pwd\depot_tools.zip
[System.IO.Compression.ZipFile]::ExtractToDirectory("$pwd\depot_tools.zip", "$pwd\depot_tools")

$env:Path = "$pwd\depot_tools" + ";" + $env:Path
$env:DEPOT_TOOLS_WIN_TOOLCHAIN = 0
$env:GYP_GENERATORS = "msvs-ninja,ninja"
$env:GYP_MSVS_VERSION = "2015"
$env:GYP_DEFINES = "v8_enable_i18n_support=0"

gclient; fetch v8; cd v8

git checkout tags/$V8VERSION
gclient sync --with_branch_heads
cd..

msbuild $pwd\v8\build\all.sln /t:Build /p:Configuration=Release /p:OutputPath=c:\projects\gameplay\deps\v8\out

md $pwd\dist; Copy-Item $pwd\v8\out\Release\obj\tools\gyp\*.lib $pwd\dist
[System.IO.Compression.ZipFile]::CreateFromDirectory("$pwd\dist", "$pwd\libv8-${V8VERSION}.${BUILD}-windows-32bit.zip", [System.IO.Compression.CompressionLevel]::Optimal, $false)