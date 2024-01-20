function [LMS] = MacBoynToLMS(lOverY,sOverY,Y,LMSfactors)

l = lOverY * Y;

s = sOverY * Y;

m = Y - l;

L = l./LMSfactors(1);
M = m./LMSfactors(2);
S = s./LMSfactors(3);

LMS = [L;M;S];

