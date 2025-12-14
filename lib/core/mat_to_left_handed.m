function flipped_mat = mat_to_left_handed(mat)
    arguments
        mat (4,4)
    end
    flipped_mat = mat;
    flipped_mat(1, 2:4) = -flipped_mat(1, 2:4);
    flipped_mat(2:3, 1) = -flipped_mat(2:3, 1);
end
