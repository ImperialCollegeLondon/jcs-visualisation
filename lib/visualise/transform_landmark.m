function r = transform_landmark(p, t)
    r.lateral = t * p.lateral;
    r.medial = t * p.medial;
    r.distal = t * p.distal;
end
