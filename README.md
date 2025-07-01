# Joint Coordinate System visualisation
## Usage
- Add the folders `lib` and `new_lib` to Path.
- Run `main.m`.
- Pick the folder which contains all specimens.
```
data          <====== Pick data, not individual specimens
├── AA12
│   ├── Data
│   └── Configuration
└── AA23
    └── ...
```
It assumes the first run does not have an optimisation matrix, and uses its matrices to generate the motion for all specimens.

## Information
Some important settings are located in `defaults.m`. Make sure to check them.
### What does the code do?
1. Unzips the project configuration (`Project.sVprj`) to find transformation matrices and knee side
2. Calculates joint coordinate system (JCS) in the optimised coordinate system
3. Outputs JCS (= optimised coordinate system) and kinematics (= Grood and Suntay, unoptimised coordinate system) to csv.
