classdef Landmark
    properties
        lateral
        medial
        distal
    end

    methods
        function self = Landmark(points)
            p = reshape(points', 3, []);
            p(4,:) = 1; %% To homogeneous
            self.lateral = p(:,1);
            self.medial = p(:,2);
            self.distal = mean(p(:, 3:6), 2);
        end

        function self = pre_multiply(self, t)
            self.lateral = pagemtimes(t, self.lateral);
            self.medial = pagemtimes(t, self.medial);
            self.distal = pagemtimes(t, self.distal);
        end
        function self = post_multiply(self, t)
            self.lateral = pagemtimes(self.lateral', t);
            self.medial  = pagemtimes(self.medial', t);
            self.distal  = pagemtimes(self.distal', t);
        end

        function self = to_mm(self)
            self.lateral = self.lateral * 1000;
            self.medial  = self.medial * 1000;
            self.distal  = self.distal * 1000;
        end

        function gTt0 = into_tibia_fixed_frame(self, is_right)
            med = self.medial(1:3);
            lat = self.lateral(1:3);
            dist = self.distal(1:3);

            ucross=@(u_,v_) cross(u_,v_)/norm(cross(u_,v_),2); %define function to find unit cross product
            uvector=@(a,b) (b-a)/norm(b-a,2); %define a function to find a unit vector from a to b

            %x, y and z notation of grood and suntay 1983, however the body frame is
            %one decided upon by RvA for a particular experiment in Nov 2018 rather
            %than the body frame defined by Grood and Sunray (as the points necessary
            %to contructs G&S body frame such as the ankle joint centre were not
            %available)

            %x = Medial lateral = epicondylar axis, positive to the right, thus is
            %orientated laterally in right knee, and medially in the left knee
            %y = Anterior posterior, anterior is positive
            %z = Proximal Distal, proximal is positive
            %i,j,k correspond to unit base vectors in the x, y and z direactions

            origin = (med+lat)/2;
            k_= uvector(dist,origin); %the distal point is approximate and thus this axis is not necessarily perpendicular to epicondylar axis
            if is_right
                tempi_ = uvector(med,lat); %RIGHT KNEE, x Axis
            else
                tempi_ = uvector(lat,med); %LEFT KNEE, x Axis
            end

            j_ = ucross(k_,tempi_); % y-axis
            i_ = ucross(j_,k_); %recalculate k so perpendicular to give orthogonal coordinate system.

            if any(all(cross(k_, i_) == zeros(3,1)) | all(cross(i_, j_) == zeros(3,1)))
                error("Cross product in Tibia is zero. Double check tibial digitisation!!")
            end

            rot = eye(4);
            trans = eye(4);

            rot(1:3, 1:3) = [i_, j_, k_];
            trans(1:3, 4) = origin;

            gTt0=trans*rot; %Note this is the same as gTt0=[rot,origin';0 0 0 1];

        end
        function gTf0 = into_femur_fixed_frame(self, is_right)
            med = self.medial(1:3);
            lat = self.lateral(1:3);
            prox = self.distal(1:3);
            %defines a body fixed frame for the femur.
            %my notation, _ implies it is a vector e.g. xa_ is the direction vector of
            %the x-axis

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

            if is_right
                tempI_ = -uvector(med,lat); %RIGHT KNEE, X Axis
            else
                tempI_ = -uvector(lat,med); %LEFT KNEE, X Axis
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

        end
    end
end
