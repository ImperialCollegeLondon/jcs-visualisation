function transform = rotationsAndTranslations_v3( T,right )
%Takes a transformation matrix and outputs rotations and translations

R=[T(1:4,1:3),[0;0;0;1]];%T is translation of the femur to the tibia in the femoral reference frame
Tl=R\T; %Tl is translation of the femur to the tibia in the tibial reference frame, this can also be read as R*Tl=T

%RotationMatrixSymbolic.m is useful for seeing full rotation matricies and
%determining these formulae

%For the knee
if right
    flex = -atan2(R(2,3),R(3,3))*180/pi;
    Valg = asind(R(1,3));
    IE = -atan2(R(1,2),R(1,1))*180/pi;
else
    flex = -atan2(R(2,3),R(3,3))*180/pi;
    Valg = -asind(R(1,3));
    IE = atan2(R(1,2),R(1,1))*180/pi;

end

ML=Tl(1,4);
AP=Tl(2,4);
SI=Tl(3,4);

transform.Flexion = flex;
transform.Valgus = Valg;
transform.Internal = IE;

transform.Medial = ML; 
transform.Posterior = AP;
transform.Superior = SI;
end

