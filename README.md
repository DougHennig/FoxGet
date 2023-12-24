# FoxGet

If you've worked with Visual Studio, you've likely used NuGet, which is a package manager for .NET. The idea is that you can search for libraries you'd like to add to your application, download and install them, and then have them managed (automatically download again if files are missing, update to a new version, etc.). FoxGet is the VFP equivalent of NuGet.

The idea is that you run FoxGet when want to add a library to an application. You search for a library you're interested in and if one is found, you can download, install, and add it to your project with a single mouse click. Of course, you'll have to do the coding part such as calling the library yourself.

Currently, there's no UI, so to use FoxGet, open the project for your application and DO the installer for the library you want to add to the application (for example, CSVProcessorInstaller to install [Antonio Lopes' CSV Processor](https://github.com/atlopes/csv)). After a moment, you should see that some files were added to the project and there’s a Packages subdirectory of the project folder containing Packages.xml and the downloaded files in a folder for the component.

You may wonder why FoxGet puts the library into a Packages subdirectory of the project folder rather than in a common location other applications could reference. There are several reasons:

- That's the way NuGet works.
- If your application is in source control (such as Git), it isn't easy to include paths outside the application path in the repository.
- You may want to use different versions of a library in different applications, especially if how you call the library changes between versions.

If you interested in writing your own installer, check out the various installer PRGs to see how little code there is, as FoxGet.prg takes care of most of the tasks. For some of them (e.g. CSVProcessor and DynamicForm), it's just specifying what files to download and which to add to the project. Others (e.g. ParallelFox and VFPXWorkbookXLSX) have more work to do, such as unzipping the download and copy some or all of the files to the package folder.

There are a few things to do:

-	Creating the UI
-	Writing installers for more components
-	Some components need to go into a common place rather than the Packages subdirectory of a project folder. For example, ParallelFox.exe since it’s a COM object that gets registered.
-	Adding files to the project’s repository if there is one.
-	Handling versioning (e.g. what version of a component do you have installed).

## Release History

### 2023-12-24

* Initial release.
