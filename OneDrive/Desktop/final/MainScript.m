%% MAIN SCRIPT: Secure Cross-Border Drone Data Transmission
clc; clear; close all;

fprintf('╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║  SECURE CROSS-BORDER DRONE DATA TRANSMISSION SYSTEM           ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n\n');

[missionData, userInputs] = collectUserInputs();

if isempty(missionData)
    fprintf('Mission cancelled by user.\n');
    return;
end

fprintf('\n=== INITIALIZING DRONE SYSTEM ===\n');
drone = DroneDataTransmitter(missionData.droneID, ...
    missionData.droneLat, missionData.droneLon);
encryptionKey = drone.encryptionKey;

fprintf('\n=== PROCESSING USER DATA ===\n');
processedData = processUserData(userInputs);

drone.captureData(processedData, missionData);

fprintf('\n=== INITIALIZING GROUND STATION ===\n');
groundStation = GroundStationReceiver(missionData.groundStationID, ...
    encryptionKey, missionData.gsLat, missionData.gsLon);

pause(1);

fprintf('\n=== RECEIVING DATA AT GROUND STATION ===\n');
groundStation.receiveData();

fprintf('\n=== GROUND STATION DASHBOARD ===\n');
groundStation.displayDashboard();

visualizeSystem(drone, groundStation, missionData);

fprintf('\n╔════════════════════════════════════════════════════════════════╗\n');
fprintf('║  MISSION COMPLETE - Data Transmitted Securely                 ║\n');
fprintf('╚════════════════════════════════════════════════════════════════╝\n');
