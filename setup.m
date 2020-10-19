function setup()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% graphics defaults
set(0,'defaulttextinterpreter','latex');  
set(0, 'defaultAxesTickLabelInterpreter','latex');  
set(0, 'defaultLegendInterpreter','latex');
set(0, 'defaultAxesXGrid', 'on')
set(0, 'defaultAxesYGrid', 'on')
set(0, 'defaultAxesZGrid', 'on')
set(groot,'defaultAxesXMinorGrid','off','defaultAxesXMinorGridMode','manual');
set(groot,'defaultAxesYMinorGrid','off','defaultAxesYMinorGridMode','manual');
set(groot,'defaultAxesZMinorGrid','off','defaultAxesZMinorGridMode','manual');

%% path
restoredefaultpath();
addpath("spherical processing");

end

