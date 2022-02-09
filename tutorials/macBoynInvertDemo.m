close all 
clear all

resourcesDir =  getpref('CorticalColorMapping','CalDataFolder');
load(fullfile(resourcesDir,'ViewSonicG220fb_670.mat'),'cals');
calCell = 4;
cal = cals{calCell};
calObj = ObjectToHandleCalOrCalStruct(cal);
% S = calObj.get('S')'

bgPrimaries = [.5,.5,.5];

load T_xyzCIEPhys2.mat %T_xyzJuddVos % Judd-Vos XYZ Color matching function
SetSensorColorSpace(calObj,T_xyzCIEPhys2,S_xyzCIEPhys2);
bgXYZ= PrimaryToSensor(calObj,bgPrimaries');

load T_cones_ss2.mat
load T_CIE_Y2.mat
SetSensorColorSpace(calObj,T_cones_ss2,S_cones_ss2);
bgExcitations = PrimaryToSensor(calObj,bgPrimaries')

Y = bgXYZ(2);

[LMSfactors] = calcMacBoynLmsFactors(T_cones_ss2,T_CIE_Y2);

ls = LMSToMacBoyn(bgExcitations,T_cones_ss2,T_CIE_Y2);

[LMS] = MacBoynToLMS(ls(1),ls(2),Y,LMSfactors)