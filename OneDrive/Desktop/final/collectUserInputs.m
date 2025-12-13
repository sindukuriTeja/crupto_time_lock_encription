function [missionData, userInputs] = collectUserInputs()
    prompt = {'Enter Drone ID:', ...
              'Enter Drone Latitude (e.g., 35.6762 for Tokyo):', ...
              'Enter Drone Longitude (e.g., 139.6503 for Tokyo):', ...
              'Enter Ground Station ID:', ...
              'Enter Ground Station Latitude (e.g., 9.9312 for Kerala):', ...
              'Enter Ground Station Longitude (e.g., 76.2711 for Kerala):', ...
              'Enter Mission Description:'};
    
    dlgtitle = 'Drone Mission Configuration';
    dims = [1 60];
    definput = {'DRONE_RECON_001', '35.6762', '139.6503', ...
                'GS_INDIA_KERALA', '9.9312', '76.2711', ...
                'Border Surveillance Mission'};
    
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    if isempty(answer)
        missionData = [];
        userInputs = [];
        return;
    end
    
    missionData.droneID = answer{1};
    missionData.droneLat = str2double(answer{2});
    missionData.droneLon = str2double(answer{3});
    missionData.groundStationID = answer{4};
    missionData.gsLat = str2double(answer{5});
    missionData.gsLon = str2double(answer{6});
    missionData.missionDesc = answer{7};
    
    fprintf('✓ Mission parameters configured\n');
    
    dataChoice = questdlg('What type of data would you like to transmit?', ...
        'Data Type Selection', ...
        'Image File', 'Text Data', 'Random Data', 'Image File');
    
    switch dataChoice
        case 'Image File'
            userInputs = collectImageData();
        case 'Text Data'
            userInputs = collectTextData();
        otherwise
            userInputs.type = 'random';
            userInputs.data = randi([0 255], 1000, 1, 'uint8');
    end
end
