function transform = rotationsAndTranslations( T,right )
%Takes a transformation matrix and outputs rotations and translations
R = T;
R(1:3, 4, :) = 0; %T is translation of the femur to the tibia in the femoral reference frame
Tl=pagemldivide(R, T);%Tl is translation of the femur to the tibia in the tibial reference frame


%RotationMatrixSymbolic.m is useful for seeing full rotation matricies and
%determining these formulae

%For the knee
if right
    Rx = -atan2(R(2,3,:),R(3,3,:))*180/pi;
    Ry = asind(R(1,3,:));
    Rz = -atan2(R(1,2,:),R(1,1,:))*180/pi;
else
    Rx = atan2(R(2,3,:),R(3,3,:))*180/pi;
    Ry = -asind(R(1,3,:));
    Rz = -atan2(R(1,2,:),R(1,1,:))*180/pi;
end
transform = table();
transform.flexion = squeeze(Rx);
transform.valgus = squeeze(Ry);
transform.internal = squeeze(Rz);

transform.medial = squeeze(Tl(1,4,:)); 
transform.posterior = squeeze(Tl(2,4,:));
transform.superior = squeeze(Tl(3,4,:));
end

