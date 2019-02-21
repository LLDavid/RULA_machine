function X = proj3dpts_to_2dpl(p1,p2,p3,p4,pt)
% given an plane equation ax+by+cz=d, project points xyz onto the plane
% return the coordinates of the new projected points
% written by Neo Jing Ci, 11/7/18
A=[1 0 0 -p1; 0 1 0 -p2; 0 0 1 -p3; p1 p2 p3 0];
B=[pt(:); p4];
X=A\B;
X=X(1:3);
end


