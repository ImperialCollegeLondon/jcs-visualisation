# Simvitro Settings Serialisation
Takes a configuration file path and serialises it.

## Basic usage
```matlab
path = /path/to/specimen/root;
fp_config = fullfile(path, "Configuration");
fp_knee_state = fullfile(fp_config, "State.cfg");
fp_setup = fullfile(fp_config, "Setup.cfg");

unzip(fullfile(fp_config, "Project.sVprj"), fp_config);

config = serialise(fp_knee_state);
setup = serialise(fp_setup);
```
