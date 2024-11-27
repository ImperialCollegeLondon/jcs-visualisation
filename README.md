# Joint Coordinate System visualisation
## Usage
Run `main.m` with matlab on Windows.
Pick the unoptimised trajectory directory (e.g, `/path/to/AA12/90N_flexion`, the one that contains `Data/` and `Configuration/`).
All other trajectories in the parent folder (`/path/to/AA12`) will run and use the unoptimised run as its Grood and Suntay JCS.

## Information
### I need to compare desired to actual forces
The struct `JCS_raw`, output of `tdms_extract()`, has the fields `translations` and `forces`.
Each of them has a `desired` and `actual` field.

### Why only Windows?
The routine was implemented using `tdmsread()`, which requires the Data Acquisition Toolbox, that is currently not available on Linux.

### What does the code do?
1. Unzips the project configuration (`Project.sVprj`) to find transformation matrices and knee side
2. Calculates joint coordinate system (JCS) in the optimised coordinate system
3. Outputs JCS (= optimised coordinate system) and kinematics (= Grood and Suntay, unoptimised coordinate system) to csv.
