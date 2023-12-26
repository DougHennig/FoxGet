# FoxGet

If you've worked with Visual Studio, you've likely used NuGet, which is a package manager for .NET. The idea is that you can search for libraries you'd like to add to your application, download and install them, and then have them managed (automatically download again if files are missing, update to a new version, etc.). FoxGet is the VFP equivalent of NuGet.

The idea is that you run FoxGet when want to add a library to an application. You search for a library you're interested in and if one is found, you can download, install, and add it to your project with a single mouse click. Of course, you'll have to do the coding part such as calling the library yourself.

Note: in this documentation, "package" means a library you want to add to your application.

## Using FoxGet

Open the project for your application and DO FoxGet.app in the FoxGet folder.

![](foxget.png)

Select a package to see information about it at the right, including the version and date the package was installed in the project if it was installed. Click the link for _Project URL_ to go to the home URL for the package.

You can search for a package by name, tag, or description by typing in the Search textbox. To show only packages installed in the current project, turn on _Show only installed packages_.

To install the selected package, click Install; that button is disabled if the package has already been installed. After a moment, you should see that some files were added to the project and there's a Packages subdirectory of the project folder containing Packages.xml and the downloaded files in a folder for the component. The package folder also contains a file named <i>Package</i>Installer.prg, which is used to uninstall the package.

You may wonder why FoxGet puts the library into a Packages subdirectory of the project folder rather than in a common location other applications could reference. There are several reasons:

- That's the way NuGet works.
- If your application is in source control (such as Git), it isn't easy to include paths outside the application path in the repository.
- You may want to use different versions of a library in different applications, especially if how you call the library changes between versions.

To uninstall the selected package, click the Uninstall button. The files added to the project by the installer are removed from the project, the package folder in the Packages subdirectory is deleted, and Packages.xml is updated.

If there's a newer version of the package available, the Update button is enabled. Clicking it uninstalls the package then installs the new version.

## Creating an installer
If you interested in writing your own installer, check out the various installer PRGs to see how little code there is, as FoxGet.prg takes care of most of the tasks. For some of them (e.g. CSVProcessor and DynamicForm), it's just specifying what files to download and which to add to the project. Others (e.g. ParallelFox and VFPXWorkbookXLSX) have more work to do, such as unzipping the download and copy some or all of the files to the package folder.

Here are some notes:

- The installer class name and PRG must be the same and match the name in the Name column of FoxGetPackages.dbf with an "Installer" extension. For example for the CSVProcessor package, the installer name is CSVProcessorInstaller.prg and the class in that file is named CSVProcessorInstaller.


## ToDo

There are a few things to do:

-   Add to Thor Check for Updates
-	Writing installers for more components
-	Some components need to go into a common place rather than the Packages subdirectory of a project folder. For example, ParallelFox.exe since it’s a COM object that gets registered.
-	Adding files to the project’s repository if there is one.

## Release History

### 2023-12-26

* Implemented UI and more features.

### 2023-12-24

* Initial release.
