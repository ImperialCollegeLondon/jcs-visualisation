function self = correct_end_effector(self)
    arguments
        self Experiment
    end
% self.RawTrajectorySets.correction_matrix

specimens = unique([self.RawTrajectorySets.specimen]);
states = unique([self.RawTrajectorySets.state]);
loading_conditions = unique([self.Trajectories.LoadingCondition]);
corrected_signal = 'corrected_jcs_digitised';
for sp = 1:numel(specimens)
    specimen = specimens(sp);
    is_specimen_set = [self.RawTrajectorySets.specimen] == specimen;
    is_specimen_traj = [self.Trajectories.SpecimenName] == specimen;
    for st = 1:numel(states)
        state = states(st);

        is_state_set = [self.RawTrajectorySets.state] == state;
        is_state_traj = [self.Trajectories.SpecimenState] == state;

        current_set = self.RawTrajectorySets(is_state_set & is_specimen_set);
        is_right_knee = current_set.is_right_knee;

        correction_matrices = {current_set.correction_matrix};

        % figure;
        for lc = 1:numel(loading_conditions)
            loading_condition = loading_conditions(lc);
            is_loading_condition = [self.Trajectories.LoadingCondition] == loading_condition;

            is_current = is_specimen_traj & is_state_traj & is_loading_condition;
            current_trajectories = [self.Trajectories(is_current)];
            
            % nexttile(lc);
            % title(loading_condition)


            n = max(numel(current_trajectories), 1);
            for c = 1:n
                correction_matrix = correction_matrices{c};
               
                current_trajectory = current_trajectories;
                datum = current_trajectory.Data.jcs_digitised;
                xyz = [datum.medial, datum.posterior, datum.superior];
                rxryrz = [datum.flexion, datum.valgus, datum.internal_rotation];

                mat = findTrackerFixedFrames(rxryrz, xyz);
                corrected_mat = pagemtimes(correction_matrix, mat);

                motion = rotationsAndTranslations(corrected_mat, is_right_knee);

                self.Trajectories(is_state_traj & is_specimen_traj & is_loading_condition).Data.(corrected_signal) = motion;
                % for i = 1:round(size(mat, 3)/2)
                % visualise_matrix(mat(:, :, i), ':');
                % hold on;
                % 
                % visualise_matrix(corrected_mat(:, :, i), '-');
                % end
                % hold off;
            end
        end

        % sgtitle([specimen state]);


    end
end
end