% script to run the cross val 
close all; clear all; 
crossValidateOneVsTwoMech('MAB','nCrossValIter',150,'makeAndSavePlot',true)

close all; clear all; 
crossValidateOneVsTwoMech('BMC','nCrossValIter',150,'makeAndSavePlot',true)

close all; clear all; 
crossValidateOneVsTwoMech('KAS','nCrossValIter',150,'makeAndSavePlot',true)