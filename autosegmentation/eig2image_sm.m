function [vec1eig,vec2eig,vec1x,vec1y,vec2x,vec2y]=eig2image_sm(fxx,fxy,fyy)

vec1x=-((-fxx+fyy+  (fxx.^2+4*(fxy.^2)-2*fxx.*fyy+fyy.^2).^(0.5)  )./(2*fxy));
vec1y=1;

vec2x=-((-fxx+fyy-  (fxx.^2+4*(fxy.^2)-2*fxx.*fyy+fyy.^2).^(0.5)  )./(2*fxy));
vec2y=1;

vec1mag= (vec1x.^2 + vec1y.^2).^(0.5);
vec1x=vec1x./vec1mag;
vec1y=vec1y./vec1mag;

vec2mag= (vec2x.^2 + vec2y.^2).^(0.5);
vec2x=vec2x./vec2mag;
vec2y=vec2y./vec2mag;


vec1eig=0.5*(fxx+fyy- (fxx.^2+4*fxy.^2-2*fxx.*fyy+fyy.^2).^(0.5)  );

vec2eig=0.5*(fxx+fyy+ (fxx.^2+4*fxy.^2-2*fxx.*fyy+fyy.^2).^(0.5)  );














