function [toolMn,coil_A,coil_B,coil_C] = ConstructAFPM2DExample(t_y, t_m, g, h, w_m, w_c, w, p, Q, linspeed)
maxEleRemesh = 2; % max element size for remesh region
toolMn = MagNet();
toolMn.open(0,0,true); % open MagNet
toolMn.setDefaultLengthUnit('millimeters', false); % set default length units

%% Draw geometry

% Stator VA
csStatorVA = CrossSectSolidRectangle( ...
        'name', 'csStatorVA', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(h + g/2),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y + 3*g/4]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compStatorVA = Component( ...
        'name', 'compStatorVA', ...
        'crossSections', csStatorVA, ...
        'material', MaterialGeneric('name', 'Virtual Air'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compStatorVA.make(toolMn, toolMn);
toolMn.viewAll();

% Rotor 1 Air

csRotorAir1 = CrossSectSolidRectangle( ...
        'name', 'csRotorAir1', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(t_y + t_m + 1),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,-1]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compRotorAir1 = Component( ...
        'name', 'compRotorAir1', ...
        'crossSections', csRotorAir1, ...
        'material', MaterialGeneric('name', 'AIR'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compRotorAir1.make(toolMn, toolMn);
toolMn.viewAll();

% Rotor 1 VA

csRotor1VA = CrossSectSolidRectangle( ...
        'name', 'csRotor1VA', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(g/4),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compRotor1VA = Component( ...
        'name', 'compRotor1VA', ...
        'crossSections', csRotor1VA, ...
        'material', MaterialGeneric('name', 'Virtual Air'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compRotor1VA.make(toolMn, toolMn);
toolMn.viewAll();

% Rotor 1 remesh

csRotor1Remesh = CrossSectSolidRectangle( ...
        'name', 'csRotor1Remesh', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(g/4),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y + g/4]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compRotor1Remesh = Component( ...
        'name', 'compRotor1Remesh', ...
        'crossSections', csRotor1Remesh, ...
        'material', MaterialGeneric('name', 'AIR'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compRotor1Remesh.make(toolMn, toolMn);
toolMn.viewAll();

% Rotor 2 Air

csRotorAir2 = CrossSectSolidRectangle( ...
        'name', 'csRotorAir2', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(t_y + t_m + 1),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y + 8*g/4 + h]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compRotorAir2 = Component( ...
        'name', 'compRotorAir2', ...
        'crossSections', csRotorAir2, ...
        'material', MaterialGeneric('name', 'AIR'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compRotorAir2.make(toolMn, toolMn);
toolMn.viewAll();

% Rotor 2 VA

csRotor2VA = CrossSectSolidRectangle( ...
        'name', 'csRotor2VA', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(g/4),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y + 7*g/4 + h]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compRotor2VA = Component( ...
        'name', 'compRotor2VA', ...
        'crossSections', csRotor2VA, ...
        'material', MaterialGeneric('name', 'Virtual Air'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compRotor2VA.make(toolMn, toolMn);
toolMn.viewAll();

% Rotor 2 remesh

csRotor2Remesh = CrossSectSolidRectangle( ...
        'name', 'csRotor2Remesh', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(g/4),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y + 6*g/4 + h ]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compRotor2Remesh = Component( ...
        'name', 'compRotor2Remesh', ...
        'crossSections', csRotor2Remesh, ...
        'material', MaterialGeneric('name', 'AIR'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compRotor2Remesh.make(toolMn, toolMn);
toolMn.viewAll();

% Stator Remesh 1

csStator1Remesh = CrossSectSolidRectangle( ...
        'name', 'csStator1Remesh', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(g/4),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y + g/2]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compStator1Remesh = Component( ...
        'name', 'compStator1Remesh', ...
        'crossSections', csStator1Remesh, ...
        'material', MaterialGeneric('name', 'AIR'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compStator1Remesh.make(toolMn, toolMn);
toolMn.viewAll();

% Stator Remesh 2

csStator2Remesh = CrossSectSolidRectangle( ...
        'name', 'csStator2Remesh', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(g/4),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,t_m + t_y + 5*g/4 + h]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compStator2Remesh = Component( ...
        'name', 'compStator2Remesh', ...
        'crossSections', csStator2Remesh, ...
        'material', MaterialGeneric('name', 'AIR'), ...
        'makeSolid', MakeExtrude( ...
            'location', Location3D( ...
                'anchor_xyz', DimMillimeter([0,0,0]), ...
                'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compStator2Remesh.make(toolMn, toolMn);
toolMn.viewAll();

% Rotor Iron 1

csRotorIron1 = CrossSectSolidRectangle( ...
        'name', 'RotorIron1', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(t_y),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([0,0]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
iron1 = Component( ...
        'name', 'iron1', ...
        'crossSections', csRotorIron1, ...
        'material', MaterialGeneric('name', 'Arnon 5'), ...
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
iron1.make(toolMn, toolMn);
toolMn.viewAll();

% Magnets 1

csmagnet1s = CrossSectSolidRectangle( ...
        'name', 'csmag1s', ...
        'dim_w',DimMillimeter(w_m/2),....
        'dim_h',DimMillimeter(t_m),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([0,t_y]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compMag1s = Component( ...
        'name', 'mag1s', ...
        'crossSections', csmagnet1s, ...
        'material', MaterialGeneric('name', 'Recoma 33E;Type=Uniform;Direction=[0,-1,0]'), ... 
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
compMag1s.make(toolMn, toolMn);
mn_d_setparameter(toolMn.doc, compMag1s.name,...
     'MaterialDirection','[0, 1, 0]',get(toolMn.consts,'InfoArrayParameter'));    
toolMn.viewAll();

for i = 1:2*p - 1
    csmagnet1(i) = CrossSectSolidRectangle( ...
        'name', ['csmag1' num2str(i)], ...
        'dim_w',DimMillimeter(w_m),....
        'dim_h',DimMillimeter(t_m),...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([w_m/2 + w_m*(i-1),t_y]), ...
            'theta', DimDegree(0).toRadians() ...
        ) ...
        );
    compMag1(i) = Component( ...
        'name', ['mag1' num2str(i)], ...
        'crossSections', csmagnet1(i), ...
        'material', MaterialGeneric('name', 'Recoma 33E;Type=Uniform;Direction=[0,-1,0]'), ... 
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
       dir = -2*mod(i,2) + 1;
       compMag1(i).make(toolMn, toolMn);
       mn_d_setparameter(toolMn.doc, compMag1(i).name, 'MaterialDirection',...
           sprintf('[0, %i, 0]',dir),get(toolMn.consts,'InfoArrayParameter'));
       toolMn.viewAll();
end

csmagnet1e = CrossSectSolidRectangle( ...
        'name', 'csmag1e', ...
        'dim_w',DimMillimeter(w_m/2),....
        'dim_h',DimMillimeter(t_m),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([w_m/2 + w_m*(2*p-1),t_y]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compMag1e = Component( ...
        'name', 'mag1e', ...
        'crossSections', csmagnet1e, ...
        'material', MaterialGeneric('name', 'Recoma 33E;Type=Uniform;Direction=[0,-1,0]'), ... 
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
compMag1e.make(toolMn, toolMn);
mn_d_setparameter(toolMn.doc, compMag1e.name, 'MaterialDirection',...
    sprintf('[0, 1, 0]'),get(toolMn.consts,'InfoArrayParameter'));
toolMn.viewAll();

% Rotor Iron 2

csRotorIron2 = CrossSectSolidRectangle( ...
        'name', 'RotorIron2', ...
        'dim_w',DimMillimeter(w_m*2*p),....
        'dim_h',DimMillimeter(t_y),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([0,t_y + 2*t_m + 2*g + h]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
iron2 = Component( ...
        'name', 'iron2', ...
        'crossSections', csRotorIron2, ...
        'material', MaterialGeneric('name', 'Arnon 5'), ...
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
iron2.make(toolMn, toolMn);
toolMn.viewAll();

% Magnets 2

csmagnet2s = CrossSectSolidRectangle( ...
        'name', 'csmag2s', ...
        'dim_w',DimMillimeter(w_m/2),....
        'dim_h',DimMillimeter(t_m),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([0,t_y + t_m + 2*g + h]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compMag2s = Component( ...
        'name', 'mag2s', ...
        'crossSections', csmagnet2s, ...
        'material', MaterialGeneric('name', 'Recoma 33E;Type=Uniform;Direction=[0,-1,0]'), ...  
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
            'dim_depth', DimMillimeter(16.6)) ...
        );
compMag2s.make(toolMn, toolMn);
mn_d_setparameter(toolMn.doc, compMag2s.name, 'MaterialDirection',...
    sprintf('[0, 1, 0]'),get(toolMn.consts,'InfoArrayParameter'));
toolMn.viewAll();

for i = 1:2*p - 1
    csmagnet2(i) = CrossSectSolidRectangle( ...
        'name', ['csmag2' num2str(i)], ...
        'dim_w',DimMillimeter(w_m),....
        'dim_h',DimMillimeter(t_m),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([w_m/2 + w_m*(i-1),t_y + t_m + 2*g + h]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
    compMag2(i) = Component( ...
        'name', ['mag2' num2str(i)], ...
        'crossSections', csmagnet2(i), ...
        'material', MaterialGeneric('name', 'Recoma 33E;Type=Uniform;Direction=[0,-1,0]'), ... 
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
    dir = -2*mod(i,2) + 1;
    compMag2(i).make(toolMn, toolMn);
    mn_d_setparameter(toolMn.doc, compMag2(i).name, 'MaterialDirection',...
            sprintf('[0, %i, 0]',dir),get(toolMn.consts,'InfoArrayParameter'));
    toolMn.viewAll();
end


csmagnet2e = CrossSectSolidRectangle( ...
        'name', 'csmag2e', ...
        'dim_w',DimMillimeter(w_m/2),....
        'dim_h',DimMillimeter(t_m),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([w_m/2 + w_m*(2*p-1),t_y + t_m + 2*g + h]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
compMag2e = Component( ...
        'name', 'mag2e', ...
        'crossSections', csmagnet2e, ...
        'material', MaterialGeneric('name', 'Recoma 33E;Type=Uniform;Direction=[0,-1,0]'), ... 
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
    compMag2e.make(toolMn, toolMn);
    mn_d_setparameter(toolMn.doc, compMag2e.name, 'MaterialDirection',...
        sprintf('[0, 1, 0]'),get(toolMn.consts,'InfoArrayParameter'));
    toolMn.viewAll();


% Inward Coils
for i = 1:Q
    csCoilIn(i) = CrossSectSolidRectangle( ...
        'name', ['csCoilIn' num2str(i)], ...
        'dim_w',DimMillimeter(w),....
        'dim_h',DimMillimeter(h),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([w_c/2 - w + w_c*(i-1),t_y + t_m + g]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
    compCoilIn(i) = Component( ...
        'name', ['compCoilIn' num2str(i)], ...
        'crossSections', csCoilIn(i), ...
        'material', MaterialGeneric('name', 'Copper: 5.77e7 Siemens/meter'), ...  
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
    compCoilIn(i).make(toolMn, toolMn);
    toolMn.viewAll();
end

% Outward Coils
  for i = 1:Q
    csCoilOut(i) = CrossSectSolidRectangle( ...
        'name', ['csCoilOut' num2str(i)], ...
        'dim_w',DimMillimeter(w),....
        'dim_h',DimMillimeter(h),...
        'location', Location2D( ...
        'anchor_xy', DimMillimeter([w_c/2+w_c*(i-1),t_y + t_m + g]), ...
        'theta', DimDegree(0).toRadians() ...
        ) ...
        );
    compCoilOut(i) = Component( ...
        'name', ['compCoilOut' num2str(i)], ...
        'crossSections', csCoilOut(i), ...
        'material', MaterialGeneric('name', 'Copper: 5.77e7 Siemens/meter'), ...  
        'makeSolid', MakeExtrude( ...
        'location', Location3D( ...
        'anchor_xyz', DimMillimeter([0,0,0]), ...
        'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
                ), ...
        'dim_depth', DimMillimeter(16.6)) ...
        );
    compCoilOut(i).make(toolMn, toolMn);
    toolMn.viewAll();
    
   end

%% Make Coils
    coil_A = mn_d_makeSimpleCoil(toolMn.mn, 1, [{['compCoilIn' num2str(1)]}, {['compCoilOut' num2str(3)]}]);
    mn_d_setparameter(toolMn.doc, coil_A, 'NumberOfTurns', 20, ...
    get(toolMn.consts,'infoNumberParameter'));
    coil_B = mn_d_makeSimpleCoil(toolMn.mn, 1, [{['compCoilIn' num2str(3)]}, {['compCoilOut' num2str(2)]}]);
    mn_d_setparameter(toolMn.doc, coil_B, 'NumberOfTurns', 20, ...
    get(toolMn.consts,'infoNumberParameter'));
    coil_C = mn_d_makeSimpleCoil(toolMn.mn, 1, [{['compCoilIn' num2str(2)]}, {['compCoilOut' num2str(1)]}]);
    mn_d_setparameter(toolMn.doc, coil_C, 'NumberOfTurns', 20, ...
    get(toolMn.consts,'infoNumberParameter'));

%% Setup Mesh
    mn_d_setparameter(toolMn.doc, compRotor1Remesh.name, 'MaximumElementSize', ...
    sprintf('%g %%mm', maxEleRemesh), ...
    get(toolMn.consts,'infoNumberParameter'));
    mn_d_setparameter(toolMn.doc, compRotor2Remesh.name, 'MaximumElementSize', ...
    sprintf('%g %%mm', maxEleRemesh), ...
    get(toolMn.consts,'infoNumberParameter'));
    mn_d_setparameter(toolMn.doc, compStator1Remesh.name, 'MaximumElementSize', ...
    sprintf('%g %%mm', maxEleRemesh), ...
    get(toolMn.consts,'infoNumberParameter'));
    mn_d_setparameter(toolMn.doc, compStator2Remesh.name, 'MaximumElementSize', ...
    sprintf('%g %%mm', maxEleRemesh), ...
    get(toolMn.consts,'infoNumberParameter'));

%% Set up Periodic Boundary Conditions
bc_path = mn_d_createBoundaryCondition(toolMn.mn, [{'compStatorVA,Face#4'},{'compRotorAir1,Face#4'},...
     {'compRotorAir2,Face#4'},{'compRotor1Remesh,Face#4'},{'compRotor1VA,Face#4'},{'compRotor2VA,Face#4'},{'compRotor2Remesh,Face#4'},...
      {'compStator1Remesh,Face#4'},{'compStator2Remesh,Face#4'}], 'Boundary1' );
status = mn_d_setEvenPeriodic(toolMn.mn,bc_path,[], [], [], [], [-2*p*w_m 0 0], []);
 
%% Set up Motion component
    motion = mn_d_makeMotionComponent(toolMn.mn, [{'compCoilIn1'}, {'compCoilIn2'},{'compCoilIn3'}...
    {'compCoilOut1'},{'compCoilOut2'},{'compCoilOut3'},{'compStator2Remesh'},{'compStator1Remesh'},{'compStatorVA'}]);
    positionAtStartup = 0;
    speedAtStartup = 0;
    timeArray = 0;
    speedArray = linspeed;
    direction = [-1,0,0];

%% Set motion parameters
    mn_d_setparameter(toolMn.doc, motion, 'MotionSourceType','VelocityDriven', ...
    get(toolMn.consts,'InfoStringParameter'));
    mn_d_setparameter(toolMn.doc, motion, 'MotionType','Linear', ...
    get(toolMn.consts,'InfoStringParameter'));
    mn_d_setparameter(toolMn.doc, motion, 'PositionAtStartup',sprintf('%g %%mm', positionAtStartup), ...
    get(toolMn.consts,'infoNumberParameter'));
    mn_d_setparameter(toolMn.doc, motion, 'SpeedAtStartup',speedAtStartup, ...
    get(toolMn.consts,'infoNumberParameter'));
    mn_d_setparameter(toolMn.doc, motion, 'SpeedVsTime',sprintf('[%g %%ms, %g]', timeArray, speedArray), ...
    get(toolMn.consts,'InfoArrayParameter'));
    mn_d_setparameter(toolMn.doc, motion, 'MotionDirection',sprintf('[%g, %g, %g]', direction(1), direction(2),direction(3)), ...
    get(toolMn.consts,'InfoArrayParameter'));
end


