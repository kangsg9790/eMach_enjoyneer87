function ANALYSIS(refMotFilePath, NumberOfPorts, NumberOfCases, DoETable, FixVariableTable, message_on)
%% 병렬풀 초기화 및 배치
delete(gcp('nocreate'));  % 사전에 실행 중인 병렬 풀 있을까봐 끄고 시작
parpool(NumberOfPorts);  % 병렬 풀 생성, default가 Processes, Threads로 하면 에러

%% spmd loop, numPorts 병렬 실행
if message_on>0
    time_before_spmd=datetime;
    disp(['The ', num2str(NumberOfPorts), ' ports ', num2str(NumberOfCases), ' cases spmd start'])
    disp(['Time at spmd start : ', char(time_before_spmd)])
end
spmd

    %% spmdIndex
    activeServers(spmdIndex)=actxserver('motorcad.appautomation');
    invoke(activeServers(spmdIndex), 'SetVariable', 'MessageDisplayState', 2); % 모든 메시지를 별도의 창에 표시하도록 설정 - 주의: 이로 인해 파일 저장, 데이터 덮어쓰기 등 중요한 팝업 메시지가 비활성화될 수 있으니 주의하시기 바랍니다.
    invoke(activeServers(spmdIndex), 'LoadFromFile', refMotFilePath);

    for OrderInPort = 1:1:(NumberOfCases/NumberOfPorts)
        % parallel case number seperation
        CaseNumber = (spmdIndex-1)*(NumberOfCases/NumberOfPorts)+OrderInPort;
        if message_on>1
            disp(['case ',num2str(CaseNumber),' start'])
            disp(['Time at case start : ', char(datetime)])
        end

        % New Folder and File Address
        parts = strsplit(refMotFilePath, filesep);
        parentPath = fullfile(parts{1:end-2});
        [filepath,name,ext] = fileparts(refMotFilePath);
        newFolder = fullfile(parentPath, 'DOE', [name, '_Design', sprintf('%03d', CaseNumber)]);
        parts = strsplit(newFolder, filesep);
        newMotFilePath = fullfile(newFolder, strcat(parts{end}, '.mot'));
        resultcheckfolder=[newFolder '\' 'resultcheck'];  % 해석 완료된 모델 체크용

        % StatorVariable Struct
        StatorVariable=McadStatorVariable([]);
        StatorVariable.SlotType=2;  % slot type : parallel slot
        StatorVariable.Slot_Number=FixVariableTable.Slot_Number;  % 외부에서 당겨옴, 상수, 고정
        StatorVariable.Stator_Lam_Dia=FixVariableTable.Stator_Lam_Dia;  % 외부에서 당겨옴, 상수, 고정
        StatorVariable.Tooth_Tip_Depth=FixVariableTable.Tooth_Tip_Depth;  % 외부에서 당겨옴, 상수, 고정
        StatorVariable.Tooth_Tip_Angle=DoETable.Tooth_Tip_Angle(CaseNumber);  % 상수
        % StatorVariable.Stator_Bore=StatorVariable.Stator_Lam_Dia*DoETable.Ratio_Bore(caseNum);  % 상수
        % StatorVariable.Slot_Depth=(StatorVariable.Stator_Lam_Dia-StatorVariable.Stator_Bore)*DoETable.Ratio_SlotDepth_ParallelSlot(caseNum);  % 상수
        % StatorVariable.Slot_Width=(StatorVariable.Stator_Lam_Dia-StatorVariable.Stator_Bore-StatorVariable.Slot_Depth)*DoETable.i_YtoT(caseNum);  % 상수
        % StatorVariable.Slot_Opening=StatorVariable.Slot_Width*DoETable.Ratio_SlotOpening_ParallelSlot(caseNum);  % 상수
        % StatorVariable.Sleeve_Thickness=0;  % 상수
        StatorVariable.Ratio_Bore=DoETable.Ratio_Bore(CaseNumber);  % 비율
        StatorVariable.Ratio_SlotDepth_ParallelSlot=DoETable.Ratio_SlotDepth_ParallelSlot(CaseNumber);  % 비율
        temp_StatorBore=StatorVariable.Stator_Lam_Dia*StatorVariable.Ratio_Bore;  % 계산용
        temp_BackYoke=(StatorVariable.Stator_Lam_Dia-temp_StatorBore)/2*(1-StatorVariable.Ratio_SlotDepth_ParallelSlot);  % 계산용
        temp_Slot_Width_max=temp_BackYoke/DoETable.i_YtoT(CaseNumber);  % 계산용
        StatorVariable.Ratio_SlotWidth=(temp_StatorBore*pi/StatorVariable.Slot_Number)/temp_Slot_Width_max;  % 비율
        StatorVariable.Ratio_SlotOpening_ParallelSlot=DoETable.Ratio_SlotOpening_ParallelSlot(CaseNumber);  % 비율
        StatorVariable.Ratio_SleeveThickness=0;  % 비율, 고정

        setMcadVariable(StatorVariable,activeServers(spmdIndex));

        % RotorVariable Struct (그냥 구조체가 아님, 변수 추가하려면 "motorCadGeometryRotor" 내부에서 정의 후 진행)
        RotorVariable=motorCadGeometryRotor(DoETable(CaseNumber,:),FixVariableTable.VMagnet_Layers);
        RotorVariable.BPMRotor=FixVariableTable.BPMRotor;
        RotorVariable.Pole_Number=FixVariableTable.Pole_Number;
        RotorVariable.VMagnet_Layers=FixVariableTable.VMagnet_Layers;
        % RotorVariable.Banding_Thickness=FixVariableTable.Banding_Thickness;  % 고정
        RotorVariable.Ratio_BandingThickness=FixVariableTable.Ratio_BandingThickness;  % 고정
        % RotorVariable.Shaft_Dia=FixVariableTable.Shaft_Dia;  % 고정
        temp_Rotor_Dia=StatorVariable.Stator_Lam_Dia*DoETable.Ratio_Bore(CaseNumber)-2*FixVariableTable.Airgap;
        RotorVariable.Ratio_ShaftD=FixVariableTable.Shaft_Dia/temp_Rotor_Dia;
        RotorVariable.Shaft_Dia_Front=FixVariableTable.Shaft_Dia;  % 샤프트 외경 고정
        RotorVariable.Shaft_Dia_Rear=FixVariableTable.Shaft_Dia;  % 샤프트 외경 고정
        RotorVariable.Airgap=FixVariableTable.Airgap;  % 고정
        RotorVariable.VShapeMagnetSegments_Array=FixVariableTable.VShapeMagnetSegments_Array;
        RotorVariable.BridgeThickness_Array=FixVariableTable.BridgeThickness_Array;

        setMcadVariable(RotorVariable,activeServers(spmdIndex));

        % EtcVariable Struct, Axial parameters...
        EtcVariable=struct();
        % EtcVariable.N_d_MotorLAB=DoETable.N_d_MotorLAB(caseNum);  
        % EtcVariable.Imax_MotorLAB=DoETable.Imax_MotorLAB(caseNum);  
        EtcVariable.Rotor_Lam_Length           = DoETable.ActiveLength(CaseNumber);
        EtcVariable.Stator_Lam_Length          = DoETable.ActiveLength(CaseNumber);
        EtcVariable.Magnet_Length              = DoETable.ActiveLength(CaseNumber);
        EtcVariable.Motor_Length               = DoETable.ActiveLength(CaseNumber)+100;
        EtcVariable.AxialSegments              = FixVariableTable.AxialSegments;  % 영구자석 축방향 분할

        setMcadVariable(EtcVariable,activeServers(spmdIndex));
   
        % Winding
        settedConductorData=struct();
        NewConductorData=struct();
        settedConductorData.Armature_CoilStyle = FixVariableTable.Armature_CoilStyle;  % Coil Style : Hairpin
        settedConductorData.Insulation_Thickness = FixVariableTable.Insulation_Thickness;  % 도체 절연체 두께
        settedConductorData.Liner_Thickness = FixVariableTable.Liner_Thickness;  % 절연지 두께
        settedConductorData.WindingLayers=FixVariableTable.WindingLayers;  % 슬롯 내 턴 수
        settedConductorData.ParallelPaths_Hairpin=FixVariableTable.ParallelPaths_Hairpin;  % 병렬 수
        % settedConductorData.ConductorsPerSlot=FixVariableTable.ConductorsPerSlot;  % WindingLayers 에 따라 자동으로 적용됨
        settedConductorData.ConductorSeparation = FixVariableTable.ConductorSeparation;  % 방사방향 도체 사이 거리
        settedConductorData.Conductor2LinerSeparation=0.05;  % 도체와 Liner사이 거리
        settedConductorData.temp_fillfactor = FixVariableTable.temp_fillfactor;  % temp
        settedConductorData.HairpinWindingPatternMethod = FixVariableTable.HairpinWindingPatternMethod;  % Improved
        settedConductorData.MagThrow = FixVariableTable.MagThrow;  % 권선 피치

        setMcadVariable(settedConductorData,activeServers(spmdIndex));
        
        % 형상 적용을 위한 저장
        activeServers(spmdIndex).SaveToFile(newMotFilePath);  

        % Hair-pin coil
        validGeometry=activeServers(spmdIndex).CheckIfGeometryIsValid(1);  % Motor-CAD 자체 기능
        if validGeometry==1
            activeServers(spmdIndex).SetVariable('MessageDisplayState', 2);
            [Success,settedConductorData.Area_Slot]=activeServers(spmdIndex).GetVariable('Area_Slot');  % 슬롯 영역 넓이
            [Success,settedConductorData.Area_Winding_With_Liner]=activeServers(spmdIndex).GetVariable('Area_Winding_With_Liner');  % 직사각각형 슬롯 영역 넓이
            [Success,settedConductorData.Slot_Width]= activeServers(spmdIndex).GetVariable('Slot_Width');  % 슬롯 너비 (회전방향)
            [Success,settedConductorData.Winding_Depth]=activeServers(spmdIndex).GetVariable('Winding_Depth');  % 직사각형 슬롯 깊이 (방사방향)
            % [Success,settedConductorData.Slot_Depth]= activeServers(spmdIndex).GetVariable('Slot_Depth');  % 슬롯 깊이 (방사방향)
            NewConductorData=calcConductorSize(settedConductorData, message_on);  % 현재 셋팅된 값 기반으로 copper 사이즈 계산
        end
        setMcadVariable(NewConductorData,activeServers(spmdIndex));
        if message_on>1
            disp(['case ', num2str(CaseNumber),' setting done'])
        end

        % resultcheckfoler 기반 해석 완료된 case 넘김, 임시로 폴더 유무로 체크하게 해둠
        if ~exist(resultcheckfolder, 'dir')
            if exist(newFolder, 'dir')
                % 폴더 통체로 삭제하고 싶은데 잘 모르겠음
                if exist(newMotFilePath, 'file')
                    delete(newMotFilePath);
                    if message_on>1
                        disp('No result file delete')
                    end
                end
            else
                mkdir(newFolder);  % 폴더 생성
            end
            activeServers(spmdIndex).SaveToFile(newMotFilePath);  % 빌드 전 저장
            if message_on>1
                disp(['case ',num2str(CaseNumber),' new file save'])
            end
            
            % Geometry Check
            activeServers(spmdIndex).CheckIfGeometryIsValid(1);  % check?

            % % temporal Output
            % activeServers(spmdIndex).DoWeightCalculation();
            % [Success,o_Weight_Stat_Core]=activeServers(spmdIndex).GetVariable('Weight_Total_Stator_Lam');

            % 파일 비교, build check 및 build
            FileParameters_MotorLAB=struct();
            FileParameters_MotorLAB.CurrentMotFilePath_MotorLAB=[];
            FileParameters_MotorLABFieldsName=fieldnames(FileParameters_MotorLAB);
            [Success,charTypeData]=activeServers(spmdIndex).GetVariable(FileParameters_MotorLABFieldsName{1});
            FileParameters_MotorLAB.(FileParameters_MotorLABFieldsName{1})=charTypeData;
            if ~isequal(refMotFilePath, FileParameters_MotorLAB.CurrentMotFilePath_MotorLAB)
                [Success, isBuildSucceeded]=activeServers(spmdIndex).GetModelBuilt_Lab();  % 모델 빌드 여부 체크
                if isBuildSucceeded==0  % 빌드 안돼있으면
                    time_before=datetime;
                    if message_on>1
                        disp(['Time before build : ', char(time_before)])
                    end

                    activeServers(spmdIndex).BuildModel_Lab();  % 빌드(해석 실행 및 자동 저장)
                    [Success, isBuildSucceeded]=activeServers(spmdIndex).GetModelBuilt_Lab();  % 모델 빌드 여부 체크
                    if isBuildSucceeded==1  % 빌드 돼있으면
                        mkdir(resultcheckfolder);  % 빌드 완료됨을 표시하는 폴더 생성
                    end
                    time_after=datetime;
                    if message_on>0
                        disp(['case ',num2str(CaseNumber),' (', num2str(OrderInPort), 'th in port ', num2str(spmdIndex),') build done'])
                        disp(['Time after build : ', char(time_after)])
                        disp(['Time cost of build : ', char(time_after-time_before)])
                    end


                    activeServers(spmdIndex).SaveToFile(newMotFilePath);  % 파일 재저장
                    
                    % Radial, Axial, Winding Screenshoot 저장
                    screens = {'Radial','StatorWinding'};
                    for j = 1:numel(screens)
                        screenname = screens{j};
                        fileName = [newFolder, '\Pic_', screenname, '.png'];
                        activeServers(spmdIndex).SaveScreenToFile(screenname, fileName);
                    end

                    activeServers(spmdIndex).LoadFromFile(refMotFilePath);  % ref 파일 땡겨오기
                end
            end
        else
            if message_on>0
                disp(['case ', num2str(CaseNumber), ' is already done, move to next case'])
            end
        end
        if message_on>1
            disp(['case ',num2str(CaseNumber),' end'])
            disp(['Time at case end : ', char(datetime)])
        end
    % for 문 끝
    end  

    if message_on>0
        disp(['port ', num2str(spmdIndex), ' loop end'])
    end

    % 종료
    invoke(activeServers(spmdIndex), 'Quit');
    activeServers=0;


% spmd end
end
if message_on>0
    time_after_spmd=datetime;
    disp(['The ', num2str(NumberOfPorts), ' ports', num2str(NumberOfCases), 'cases spmd end'])
    disp(['Time at spmd end : ', char(time_after_spmd)])
    disp(['Time cost of spmd : ', char(time_before_spmd-time_after_spmd)])
end


%% 병렬 풀
delete(gcp);

end