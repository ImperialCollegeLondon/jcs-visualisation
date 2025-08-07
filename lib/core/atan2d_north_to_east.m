function corrected = atan2d_north_to_east(x)
    corrected = zeros(size(x));
    mask = (x <= -90) & (x > -180);
    corrected(mask) = -270 - x(mask);
    corrected(~mask) = 90 - x(~mask);
end