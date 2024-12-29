function [output,z_proj_y2,orig] = calculateCS_change(matrix1, matrix2, matrix3, matrix4,matrix5)
    % Ensure input matrices have the correct dimensions
    % Add your validation here if necessary
    check_unit_vectors(matrix1);
    check_unit_vectors(matrix2);
    check_unit_vectors(matrix3);
    check_unit_vectors(matrix4);
    check_unit_vectors(matrix5);

    % Extract x, y, z columns from all matrices
    x1 = matrix1(:, 1);
    y1 = matrix1(:, 2);
    z1 = matrix1(:, 3);
    orig1 = matrix1(:, 4);

    x2 = matrix2(:, 1);
    y2 = matrix2(:, 2);
    z2 = matrix2(:, 3);
    orig2 = matrix2(:, 4);

    x3 = matrix3(:, 1);
    y3 = matrix3(:, 2);
    z3 = matrix3(:, 3);
    orig3 = matrix3(:, 4);

    x4 = matrix4(:, 1);
    y4 = matrix4(:, 2);
    z4 = matrix4(:, 3);
    orig4 = matrix4(:, 4);

    x5 = matrix5(:, 1);
    y5 = matrix5(:, 2);
    z5 = matrix5(:, 3);
   orig5 = matrix5(:, 4);

    % Calculate dot products
    dotProducts12 = [dot(x1, x2), dot(y1, y2), dot(z1, z2)];
    dotProducts13 = [dot(x1, x3), dot(y1, y3), dot(z1, z3)];
    dotProducts14 = [dot(x1, x4), dot(y1, y4), dot(z1, z4)];
    dotProducts15 = [dot(x1, x5), dot(y1, y5), dot(z1, z5)];

    % Calculate origin differences
    origin12 = sqrt(sum((orig1 - orig2).^2));
    origin13 = sqrt(sum((orig1 - orig3).^2));
    origin14 = sqrt(sum((orig1 - orig4).^2));
    origin15 = sqrt(sum((orig1 - orig5).^2));

    % Calculate angles in degrees using acosd
    angles12 = acosd(dotProducts12);
    angles13 = acosd(dotProducts13);
    angles14 = acosd(dotProducts14);
    angles15 = acosd(dotProducts15);

    output=[angles12,angles13,angles14,angles15];
    orig=[origin12,origin13,origin14,origin15];
% Calculate vector projections onto the plane created by y and z axes of matrix 1
% Calculate vector projection of z-axes onto y2 axis
    z_proj_y2_1 = dot(z1, y2) / norm(y2);
    z_proj_y2_2 = dot(z2, y2) / norm(y2);
    z_proj_y2_3 = dot(z3, y2) / norm(y2);
    z_proj_y2_4 = dot(z4, y2) / norm(y2);
    z_proj_y2_5 = dot(z5, y2) / norm(y2);

    z_proj_y2 = [z_proj_y2_1, z_proj_y2_2, z_proj_y2_3, z_proj_y2_4, z_proj_y2_5];

end

function check_unit_vectors(matrix)
    for col = 1:3
        col_vector = matrix(:, col);
        if norm(col_vector) - 1 > 0.0001
            error('Column %d in the matrix does not represent a unit vector.', col);
        end
    end
end