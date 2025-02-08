function r = landmarks(points)
    p = reshape(points', 3, []);
    p(4,:) = 1; %% To homogeneous
    r.lateral = p(:,1);
    r.medial = p(:,2);
    r.distal = mean(p(:, 4:6), 2);
end
