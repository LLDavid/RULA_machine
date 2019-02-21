function [a1,a2,a3,a4] = plfunc_from_3pts( pt1,pt2,pt3 )
normal = cross(pt1 - pt2, pt1 - pt3);
d = pt1(1)*normal(1) + pt1(2)*normal(2) + pt1(3)*normal(3);
a1=normal(1); a2=normal(2); a3=normal(3);
a4 = -d;
end

