function obj = add_transforms(obj, label, transforms)
    obj.Transform.(label) = transforms;
end
