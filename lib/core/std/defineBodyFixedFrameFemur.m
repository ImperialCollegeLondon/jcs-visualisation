function gTf0 = defineBodyFixedFrameFemur(femur,right)
med = femur.medial(1:3);
lat = femur.lateral(1:3);
prox = femur.distal(1:3);
%defines a body fixed frame for the femur.  
%my notation, _ implies it is a vector e.g. xa_ is the direction vector of
%the x-axis

angle = @(u_,v_) acosd(dot(u_,v_)/(norm(u_,2)*norm(v_,2))); %define a function to calculate the angle between two vectors
ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

%X, Y and Z notation of grood and suntay 1983, however the body frame is
%one decided upon by RvA for a particular experiment in Nov 2018 rather
%than the body frame defined by Grood and Sunray (as the points necessary
%to contructs G&S body frame such as the femoral head centre were not
%available)

%X = Medial lateral = epicondylar axis, positive to the right, thus is
%orientated laterally in right knee, and medially in the left knee
%Y = Anterior posterior, anterior is positive
%Z = Proximal Distal, proximal is positive
%I,J,K correspond to unit base vectors in the X, Y and Z direactions

origin = (med+lat)/2;

if right
    tempI_ = uvector(med,lat); %RIGHT KNEE, X Axis
else
    tempI_ = uvector(lat,med); %LEFT KNEE, X Axis
end

K_= uvector(origin,prox);
J_ = ucross(K_,tempI_);
I_ = ucross(J_,K_);

if any(all(cross(K_, I_) == zeros(3,1)) | all(cross(I_, J_) == zeros(3,1)))
error("Cross product in Femur is zero. Double check femoral digitisation!!")
end

rot = eye(4);
trans = eye(4);

rot(1:3, 1:3) = [I_, J_, K_];
trans(1:3, 4) = origin;

gTf0=trans*rot; % Note this is the same as gTf0=[rot,origin';0 0 0 1];


%check for orthogonality
% angle(I_,J_)
% angle(J_,K_)
% angle(I_,K_)

end

