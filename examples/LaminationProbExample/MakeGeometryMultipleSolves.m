% Lamination 

clc
clear
n = 1:20; %number of laminations

MES_AirBox = 2; %Maximum Element Size in air (mm)
MES_Conductors = 2; %Maximum Element Size in conductors (mm)
MES_Laminations = 0.15; %Maximum Element Size in the laminations (mm)

CoilTurns = 1000; %Number of turns on the coil
CoilCurrent = 8.5; %Amperes, current to get 1 T at the lamination center

endTime = 65; %ms
timeStep = 1; %ms
elecFreq = 20; %Hz
elecPeriod = 1/elecFreq*1e3; %ms
currentAmplitude = 8.5; %Amp

BXPoints = linspace(8,10,10); %X Coordinates to calculate fields at (mm)
BYPoint = 15;   %Y Coordinate to calculate fields at (mm)
BZPoint = 0;    %Z Coorindate to calculate fields at (mm)

%TO DO: 
%   - use a lamination steel that is conductive
%   - extract field results
%   - iterate to find desired field

for j = 1:length(n)
%% set up MagNet
toolMn = MagNet();
toolMn.open(0,0,true);
toolMn.setDefaultLengthUnit('millimeters', false);

%% MagNet Airbox
CsAir = CrossSectSolidRect( ...
        'name', 'Cond1', ...
        'dim_w',DimMillimeter(78),....
        'dim_h',DimMillimeter(90),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([-30,-30]), ...
            'theta', DimDegree([0]).toRadians() ...
        ) ...
        );
compAir = Component( ...
        'name', 'Airbox', ...
        'crossSections', CsAir, ...
        'material', MaterialGeneric('name', 'AIR'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(10)) ...
        );
compAir.make(toolMn,toolMn);
toolMn.viewAll();

%% Conductors

CsCleft = CrossSectSolidRect( ...
        'name', 'Cond1', ...
        'dim_w',DimMillimeter(2),....
        'dim_h',DimMillimeter(25),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,2.5]), ...
            'theta', DimDegree([0]).toRadians() ...
        ) ...
        );
    
CsCright = CrossSectSolidRect( ...
        'name', 'Cond2', ...
        'dim_w',DimMillimeter(2),....
        'dim_h',DimMillimeter(25),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([16,2.5]), ...
            'theta', DimDegree([0]).toRadians() ...
        ) ...
        );
    
condL = Component( ...
        'name', 'LeftCoil', ...
        'crossSections', CsCleft, ...
        'material', MaterialGeneric('name', 'Copper: 5.77e7 Siemens/meter'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(10)) ...
        );
condL.make(toolMn,toolMn);
toolMn.viewAll();

condR = Component( ...
        'name', 'RightCoil', ...
        'crossSections', CsCright, ...
        'material', MaterialGeneric('name', 'Copper: 5.77e7 Siemens/meter'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(10)) ...
        );

condR.make(toolMn,toolMn);
toolMn.viewAll();

%% Laminations
lamT = 10/n(j); %lamination thickness
for i = 1:n(j)
    lamCS(i) = CrossSectSolidRect( ...
        'name', ['csLam' num2str(i)], ...
        'dim_w',DimMillimeter(lamT),...
        'dim_h',DimMillimeter(30),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([4 + lamT*(i-1),0]), ...
            'theta', DimDegree([0]).toRadians() ...
        ) ...
        );
    
    %REPLACE THE MATERIAL WITH A CONDUCTIVE STEEL MATERIAL MODEL
    compLam(i) = Component( ...
        'name', ['Lam' num2str(i)], ...
        'crossSections', lamCS(i), ...
        'material', MaterialGeneric('name', 'M-19 24 Ga non-zero conductivity'), ... % Hiperco 50A 0.006
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(10)) ...
        );
    
    compLam(i).make(toolMn,toolMn);
    toolMn.viewAll();
end


%% Create and setup winding
coilName = mn_d_makeSimpleCoil(toolMn.mn, 1, [{'LeftCoil'}, {'RightCoil'}]);
mn_d_setparameter(toolMn.doc, coilName, 'WaveFormType', 'DC', ...
    get(toolMn.consts,'InfoStringParameter'));
mn_d_setparameter(toolMn.doc, coilName, 'Current', CoilCurrent, ...
    get(toolMn.consts,'infoNumberParameter'));
mn_d_setparameter(toolMn.doc, coilName, 'NumberOfTurns', CoilTurns, ...
    get(toolMn.consts,'infoNumberParameter'));


%% Setup Mesh
mn_d_setparameter(toolMn.doc, compAir.name, 'MaximumElementSize', ...
    sprintf('%g %%mm', MES_AirBox), ...
    get(toolMn.consts,'infoNumberParameter'));
mn_d_setparameter(toolMn.doc, condL.name, 'MaximumElementSize', ...
    sprintf('%g %%mm', MES_Conductors), ...
    get(toolMn.consts,'infoNumberParameter'));
mn_d_setparameter(toolMn.doc, condR.name, 'MaximumElementSize', ...
    sprintf('%g %%mm', MES_Conductors), ...
    get(toolMn.consts,'infoNumberParameter'));

for i = 1:length(compLam)
    mn_d_setparameter(toolMn.doc, compLam(i).name, 'MaximumElementSize', ...
    sprintf('%g %%mm', MES_Laminations), ...
    get(toolMn.consts,'infoNumberParameter'));
end

%% Solve it

% sol = invoke(toolMn.doc, 'solveStatic2d');

% Set transient options: [start time, time-step, end time]
timeSettings = [0, timeStep, endTime];
mn_d_setparameter(toolMn.doc, '', 'TimeSteps', ...
    sprintf('[%g %%ms, %g %%ms, %g %%ms]', timeSettings), ...
    get(toolMn.consts,'infoArrayParameter'));

% Change to a sinusoidal current
mn_d_setparameter(toolMn.doc, coilName, 'WaveFormType', 'SIN', ...
    get(toolMn.consts,'InfoStringParameter'));
mn_d_setparameter(toolMn.doc, coilName, 'WaveFormValues', ...
    sprintf('[0, %g, %g]', currentAmplitude, elecFreq), ...
    get(toolMn.consts,'InfoArrayParameter'));

% sol = invoke(toolMn.doc, 'solveTimeHarmonic2d');
solData = invoke(toolMn.doc, 'solveTransient2d');

%% Post-processing

% add this command to be able to pass an array from Matlab to a MagNet 

% get average iron ohmic loss: calculate average loss for each lamination
% and then sum losses of all laminations
time = mn_getTimeInstants(toolMn.mn, 1, true);
for i = 1:length(compLam)
        eOhmicLossesT = mn_readConductorOhmicLoss(toolMn.mn, ...
            toolMn.doc, compLam(i).name, 1);
        OhmicLosses(:,i) = eOhmicLossesT(:,2);
end
TotalOhmicLossesTr = sum(mean(OhmicLosses(end-round(elecPeriod/timeStep):end)));
%

% get By in region at tooth center as a function of time
thePoints = [BXPoints' BYPoint*ones(size(BXPoints')) BZPoint*ones(size(BXPoints'))];
for k = 1:length(time)
    fieldData{k} = mn_readFieldAtPoints(toolMn.mn, thePoints, ...
                                                'B', 1, time(k));
    ByAll(k,:) = fieldData{k}(:,2)'; %gather just the y direction data as a function of time
    ByAvg(k,:) = mean(fieldData{k}(:,2)); %average of y direction field near center
end

%Get coil current
current = mn_readCoilCurrent(toolMn.mn, toolMn.doc, coilName, 1);

%determine By peak:
Bypeak = max(abs(ByAvg));
figure
subplot(2,1,1)
plot(time, ByAvg)
ylabel('Field at center (T)')
subplot(2,1,2)
plot (time, current(:,2))
ylabel('Coil Current (A)')
xlabel('time (ms)')

figure
plot(time, OhmicLosses)
ylabel('Ohmic losses')
xlabel('time (ms)')

% save file and exit
FileName = [pwd '\lam_thickness_',num2str(lamT),'.mn'];
Doc=invoke(toolMn.mn, 'saveDocument', FileName);
invoke(toolMn.mn, 'exit');

%data to save
solData(j).TotalOhmicLossesTr = TotalOhmicLossesTr;
solData(j).Bypeak = Bypeak;
solData(j).ByAvg = ByAvg;
solData(j).time = time;
end

save(solData);