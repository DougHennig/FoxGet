# How to Contribute to FoxGet

## Report a bug

- Please check [issues](https://github.com/DougHennig/FoxGet/issues) if the bug has already been reported.

- If you're unable to find an open issue addressing the problem, open a new one. Be sure to include a title and clear description, as much relevant information as possible, and a code sample or an executable test case demonstrating the expected behavior that is not occurring.

## Fix a bug or add an enhancement

- Fork the project: see this [guide](https://www.dataschool.io/how-to-contribute-on-github/) for setting up and using a fork.

- See the _Creating an installer_ topic in README.md for information on creating a new installer if that's what you're doing.

- If you're making changes to the FoxGet UI or FoxGet.prg and this is a new major release, edit the Version setting in *BuildProcess\ProjectSettings.txt*.

- Describe the changes at the top of *ChangeLog.md*.

- If you haven't already done so, install VFPX Deployment: choose Check for Updates from the Thor menu, turn on the checkbox for VFPX Deployment, and click Install.

- Start VFP 9 (not VFP Advanced) and CD to the project folder.

- Run the VFPX Deployment tool to create the installation files: choose VFPX Project Deployment from the Thor Tools, Application menu. Alternately, execute ```EXECSCRIPT(_screen.cThorDispatcher, 'Thor_Tool_DeployVFPXProject')```.

- Commit the changes.

- Push to your fork.

- Create a pull request; ensure the description clearly describes the problem and solution or the enhancement.

----
Last changed: 2023-12-28