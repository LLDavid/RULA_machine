function angle=cal3dangle(v1,v2)
assert(length(v1)==length(v2),"length differ")
if length(v1)==3
    angle=atan2(norm(cross(v1,v2)), dot(v1,v2));
else
    angle=acos(dot(v1,v2)/(norm(v1)*norm(v2)));
end
end

