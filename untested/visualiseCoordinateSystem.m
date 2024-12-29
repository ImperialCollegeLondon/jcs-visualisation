function transformedMatrix = visualiseCoordinateSystem(T, colors,scale_orig,scale_vector)
% Plots a transformation matrix as a 3D coordinate system, inputs are
% (transformation matrix, colours for x,y,z, scale_orig which scales the
% origin (for example from metres to millimetres) and scale_vector, which
% scales how big the axes are

    % Extract the rotational part (3x3 matrix) from the 4x4 transformation matrix

    rotationMatrix = T(1:3, 1:3);
    
    % Extract the translational part (column vector) from the 4x4 transformation matrix
    translationVector = T(1:3, 4);

    % Define original unit vectors
    unitVectors = eye(3);

    % Apply the rotation matrix to the unit vectors
    transformedVectors = rotationMatrix * unitVectors;
    disp(transformedVectors)
    % Output the rotated X, Y, Z axes
    transformedX = transformedVectors(:, 1);
    transformedY = transformedVectors(:, 2);
    transformedZ = transformedVectors(:, 3);

%     % Translate the vectors by the translation component
%     transformedVectors = transformedVectors + translationVector';

     % Combine transformed vectors and origin into a 4x3 matrix
    transformedMatrix = [transformedVectors, translationVector];
    disp(transformedMatrix)

    % Output the origin after transformation
    origin = translationVector';

    % Plot the transformed coordinate axes
    hold on;

    quiver3(translationVector(1)*scale_orig, translationVector(2)*scale_orig, translationVector(3)*scale_orig, transformedX(1)*scale_vector, transformedX(2)*scale_vector, transformedX(3)*scale_vector, colors{1}, 'LineWidth', 2); % Transformed X-axis
    quiver3(translationVector(1)*scale_orig, translationVector(2)*scale_orig, translationVector(3)*scale_orig, transformedY(1)*scale_vector, transformedY(2)*scale_vector, transformedY(3)*scale_vector, colors{2}, 'LineWidth', 2); % Transformed Y-axis
    quiver3(translationVector(1)*scale_orig, translationVector(2)*scale_orig, translationVector(3)*scale_orig, transformedZ(1)*scale_vector, transformedZ(2)*scale_vector, transformedZ(3)*scale_vector, colors{3}, 'LineWidth', 2); % Transformed Z-axis

    xlabel('X');
    ylabel('Y');
    zlabel('Z');
%   legend('T(X)', 'T(Y)', 'T(Z)');
    hold off;
    axis equal;
    grid on;
end




% function visualiseCoordinateSystem(T, colors)
%     % Extract the rotational part (3x3 matrix) from the 4x4 transformation matrix
%     rotationMatrix = T(1:3, 1:3);
%     
%     % Extract the translational part (column vector) from the 4x4 transformation matrix
%     translationVector = T(1:3, 4);
%     % Define original unit vectors
%     unitVectors = eye(3);
% 
%     % Apply the rotation matrix to the unit vectors
%     transformedVectors = rotationMatrix * unitVectors;
% s
%     % Translate the vectors by the translation component
%     transformedVectors = transformedVectors + translationVector';
% %     transformedVectors=transformedVectors;
%     
%     % Plot the transformed coordinate axes
%     hold on;
% 
%     for i = 1:3
%         quiver3(translationVector(1), translationVector(2), translationVector(3), transformedVectors(1, i), transformedVectors(2, i), transformedVectors(3, i), colors{i}, 'LineWidth', 2); % Transformed axes
%     end
% 
%     xlabel('X');
%     ylabel('Y');
%     zlabel('Z');
%     legend('T(X)', 'T(Y)', 'T(Z)');
%     hold off;
%     axis equal;
%     grid on;
% end
