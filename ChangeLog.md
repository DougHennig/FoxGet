# FoxGet Package Manager

FoxGet is a package manager for VFP similar to the NuGet Package Manager for .NET.

## Releases

### 2025-04-06

* Updated several installers to latest versions.

### 2025-01-25

* Updated ChilkatVFP installer to 1.41.

### 2024-10-06

- Packages.dbf was replaced with Packages.xml for easier comparison and merging.

- Merged pull request #7, which provides automatic updating of FoxGetPackages.dbf.

- Added a Clear Filter button.

- Updated installer versions.

- Fixed a bug that caused an error clicking *Show only installed packages* when there aren't any. Also, in that case, the list now displays nothing rather than all packages.

- Handled failure to unzip a downloaded file better.

- FoxGet no longer adds a file to the project if it's already there when installing or tries to remove it when uninstalling.

- Logging is now done when uninstalling a package.

- Error 35 no longer occurs when downloading the packages file (note: this is actually a change in VFPXInternet.prg, which is part of [VFPX Framework](https://github.com/VFPX/VFPXFramework)). Thanks to Christof Wollenhaupt for the fix.

### 2024-08-24

* Updated installer versions.

### 2024-07-21

* Added installer for [VFPX Framework](https://github.com/VFPX/VFPXFramework).
* Updated to latest [VFPX Framework](https://github.com/VFPX/VFPXFramework).

### 2024-01-30

* Added installers for [fpCefSharp](https://github.com/cwollenhaupt/fpCefSharp), [Format](https://github.com/DougHennig/FormattingStrings), and [VFP2C32](https://github.com/ChristianEhlscheid/vfp2c32).
* Implemented [VFPX Framework](https://github.com/VFPX/VFPXFramework).

### 2024-01-07

* Added support for MyPackages, a custom list of packages, which is useful for testing or private packages.
* Added support for local installer PRGs.
* Added support for copying subdirectories of extracted files.
* Fixed minor bugs.

### 2023-12-28

* Initial release.
