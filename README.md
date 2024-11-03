# Joint Coordinate System visualisation
## Usage
Run `WIP.m` with matlab on Windows.
Pick the trajectory directory (e.g, `/path/to/AA12/90N_flexion`, the one that contains `Data/` and `Configuration/`).

## Information
### Why only Windows?
The routine was implemented using `readtms()`, which requires the Data Acquisition Toolbox, that is currently not available on Linux.

### What does the code do?
1. Unzips the project configuration (`Project.sVprj`) to find transformation matrices and knee side
2. Calculates joint coordinate system (JCS) kinematics
3. Outputs flexion and extension in separate files
