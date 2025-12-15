Print["From the script."];

Import["nice_export.wl"];

cols = {"aaa","bbbb","c"};
xx = N/@Subdivide[0,5,31];
yy = Exp[-xx^2];
data = {xx,yy,2*yy};

DoTheExport["out-math1.dat",{"This is my file.","This is a second line"},cols,data,full->False];
