classdef (Abstract) ResultMotorcadData <ResultData
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Property2
    end

    methods

        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end