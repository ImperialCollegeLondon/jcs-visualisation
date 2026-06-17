function mat = coord2mat(data)
x = data(1);
y = data(2);
z = data(3);
a = data(4);
b = data(5);
c = data(6);
mat = [
    cos(b)*cos(c), -cos(b)*sin(c), sin(b), z*sin(b) + x;
    sin(a)*sin(b)*cos(c) + cos(a)*sin(c), -sin(a)*sin(b)*sin(c) + cos(a)*cos(c), -sin(a)*cos(b), -z*sin(a)*cos(b)+y*cos(a);
    -cos(a)*sin(b)*cos(c)+sin(a)*sin(c), cos(a)*sin(b)*sin(c) + sin(a)*cos(c), cos(a)*cos(b), z*cos(a)*cos(b)+y*sin(a);
    0, 0, 0, 1
];
end
