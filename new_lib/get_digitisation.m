function fp_digitisation = get_digitisation(fp_runs, config)
    if config.is_first_run_digitisation
        fp_digitisation = fullfile(fp_runs(1).folder, fp_runs(1).name);
        return
    end
    digitisation_file_mask = contains({fp_runs.name}, config.digitisation_state_name, "IgnoreCase",true);
    if sum(digitisation_file_mask) == 1
        fp_digitisation = fullfile(fp_runs(digitisation_file_mask).folder, fp_runs(digitisation_file_mask).name);
    else
        warning("Could not determine digitisation folder. Choose it manually")
        fp_digitisation = uigetdir(fp_runs(1).folder);
    end
end