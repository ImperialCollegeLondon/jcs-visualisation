function[medial_epi,lateral_epi]=femur_projection(matrix_in,femur_width)

%%This function takes the femur to tibia transformation matrix and returns
%%the femoral epicondyles, projected onto the tibia in the transverse plane

x_proj=matrix_in(1,1:2);
orig=matrix_in(4,1:2)';
x_proj_final=(x_proj/norm(x_proj))*femur_width;
medial_epi=orig-x_proj_final;
lateral_epi=orig+x_proj_final;

end