clc
clear

DRAW_MAGNET = 1;
DRAW_TIKZ   = 0;

%% Define cross sections

stator = CrossSectLinearMotorStator( ...
        'name', 'stator', ...
        'dim_w_s', DimMillimeter(65.7), ...
        'dim_w_st', DimMillimeter(14.8), ...
        'dim_w_so', DimMillimeter(3.66), ...
        'dim_r_so', DimMillimeter(71.8), ...
        'dim_r_si', DimMillimeter(35.9), ...
        'dim_d_so', DimMillimeter(3.98), ...
        'dim_d_sp', DimMillimeter(7.46), ...
        'dim_d_sy', DimMillimeter(9.53), ...
        'dim_r_st', DimMillimeter(3), ...
        'dim_r_sf', DimMillimeter(3), ...
        'dim_r_sb', DimMillimeter(3), ...
        'dim_Q', uint8(2), ...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,0]), ...
            'rotate_xy', DimDegree([0,0]).toRadians() ...
        ) ...
        );

mover = CrossSectLinearMotorMover1( ...
        'name', 'mover', ...
        'dim_r_si', DimMillimeter(35.9), ...
        'dim_w_r', DimMillimeter(65.7), ...
        'dim_w_ra', DimMillimeter(8.24), ...
        'dim_w_rr', DimMillimeter(12.9), ...
        'dim_r_ri', DimMillimeter(17.6), ...
        'dim_d_rm', DimMillimeter(9.82), ...
        'dim_g', DimMillimeter(1.35), ...
        'dim_Q', uint8(2), ...
        'location', Location2D( ...
            'anchor_xy', DimMillimeter([0,0]), ...
            'rotate_xy', DimDegree([0,0]).toRadians() ...
        ) ...
        );    
%% Define components

cs = [stator mover];

comp1 = Component( ...
        'name', 'comp1', ...
        'cross_sections', cs, ...
        'material', MaterialGeneric('name', 'pm'), ...
        'make_solid', MakeSolidBase(), ...
        'location', Location3D( ...
            'anchor_xyz', DimMillimeter([0,0,0]), ...
            'rotate_xyz', DimDegree([0,0,0]).toRadians() ...
        ) ...
        );

%% Draw via MagNet

if (DRAW_MAGNET)
    toolMn = MagNet();
    toolMn.open(0,0,true);
    toolMn.setDefaultLengthUnit('millimeters', false);

    comp1.make(toolMn);

    toolMn.viewAll();
end

%% Draw via TikZ

if (DRAW_TIKZ)
    toolTikz = TikZ();
    toolTikz.open('output.txt');

    comp1.make(toolTikz);

    toolTikz.close();
end
