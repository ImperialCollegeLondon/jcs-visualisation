function motion = rotationsAndTranslations( T,right )
arguments
    T (4, 4, :)
    right logical
end
%Takes a transformation matrix and outputs rotations and translations
R = T;
R(1:3, 4, :) = 0; %T is translation of the femur to the tibia in the femoral reference frame
Tl=pagemldivide(R, T);%Tl is translation of the femur to the tibia in the tibial reference frame


%RotationMatrixSymbolic.m is useful for seeing full rotation matricies and
%determining these formulae

%For the knee
if right
    Rx = atan2(-R(2,3,:),R(3,3,:));
    Ry = asin(R(1,3,:));
    Rz = atan2(-R(1,2,:),R(1,1,:));
else
    Rx = atan2(-R(2,3,:),R(3,3,:));
    Ry = -asin(R(1,3,:));
    Rz = -atan2(-R(1,2,:),R(1,1,:));
end
motion = table();
motion.flexion = rad2deg(unwrap(squeeze(Rx)));
motion.valgus = rad2deg(unwrap(squeeze(Ry)));
motion.internal = rad2deg(unwrap(squeeze(Rz)));

motion.medial = squeeze(Tl(1,4,:)); 
motion.posterior = squeeze(Tl(2,4,:));
motion.superior = squeeze(Tl(3,4,:));
end

