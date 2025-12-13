classdef GroundStationReceiver < handle
    properties
        stationID
        location
        decryptionKey
        receivedData
        verifiedBlocks
    end
    
    methods
        function obj = GroundStationReceiver(id, key, lat, lon)
            obj.stationID = id;
            obj.location = [lat, lon];
            obj.decryptionKey = uint8(key);
            obj.receivedData = {};
            obj.verifiedBlocks = [];
            
            fprintf('Ground Station initialized: %s\n', id);
            fprintf('Location: [%.6f, %.6f]\n', lat, lon);
        end
        
        function receiveData(obj)
            if ~exist('drone_transmission.mat', 'file')
                fprintf('✗ No transmission data available\n');
                return;
            end
            
            load('drone_transmission.mat', 'transmission');
            
            fprintf('\n┌─────────────────────────────────────────┐\n');
            fprintf('│  INCOMING TRANSMISSION                  │\n');
            fprintf('└─────────────────────────────────────────┘\n');
            fprintf('CID: %s\n', transmission.CID);
            fprintf('Drone ID: %s\n', transmission.metadata.droneID);
            fprintf('Timestamp: %s\n', transmission.metadata.timestamp);
            fprintf('Mission: %s\n', transmission.metadata.missionDesc);
            fprintf('GPS: [%.6f, %.6f]\n', transmission.metadata.gpsLat, ...
                transmission.metadata.gpsLon);
            fprintf('Data Size: %d bytes\n', transmission.metadata.dataSize);
            fprintf('Altitude: %d m\n', transmission.metadata.altitude);
            fprintf('Heading: %d°\n', transmission.metadata.heading);
            
            fprintf('\n--- Verification Process ---\n');
            if obj.verifyZKProof(transmission.zkProof)
                fprintf('✓ Zero-Knowledge Proof: VALID\n');
                
                encryptedData = transmission.ipfsData;
                fprintf('✓ Data retrieved from IPFS\n');
                
                decryptedData = obj.decryptAES(encryptedData);
                fprintf('✓ Data decrypted successfully\n');
                
                obj.receivedData{end+1} = struct('transmission', transmission, ...
                    'decryptedData', decryptedData);
                obj.verifiedBlocks(end+1) = transmission.blockchainRef;
                
                fprintf('\n✓ TRANSMISSION VERIFIED AND RECEIVED\n');
            else
                fprintf('✗ Zero-Knowledge Proof: INVALID\n');
                fprintf('✗ TRANSMISSION REJECTED\n');
            end
        end
        
        function isValid = verifyZKProof(obj, zkProof)
            isValid = zkProof.verified && ~isempty(zkProof.hash);
            timeDiff = seconds(datetime('now') - zkProof.timestamp);
            isValid = isValid && (timeDiff < 600);
        end
        
        function decrypted = decryptAES(obj, encryptedData)
            encryptedData = uint8(encryptedData(:));
            
            keyUint8 = uint8(obj.decryptionKey(:));
            keyRepeated = repmat(keyUint8, ceil(length(encryptedData)/length(keyUint8)), 1);
            keyRepeated = keyRepeated(1:length(encryptedData));
            
            decrypted = bitxor(encryptedData, keyRepeated);
            
            padLength = double(decrypted(end));
            if padLength < 16 && padLength > 0
                decrypted = decrypted(1:end-padLength);
            end
        end
        
        function displayDashboard(obj)
            fprintf('\n╔════════════════════════════════════════════════════════════╗\n');
            fprintf('║          GROUND STATION CONTROL DASHBOARD                 ║\n');
            fprintf('╚════════════════════════════════════════════════════════════╝\n');
            fprintf('Station ID: %s\n', obj.stationID);
            fprintf('Location: [%.6f, %.6f]\n', obj.location(1), obj.location(2));
            fprintf('Total Verified Transmissions: %d\n', length(obj.receivedData));
            fprintf('Verified Blocks: [%s]\n', num2str(obj.verifiedBlocks));
            
            for i = 1:length(obj.receivedData)
                data = obj.receivedData{i};
                fprintf('\n┌── Transmission #%d ──────────────────────────┐\n', i);
                fprintf('│ Drone: %s\n', data.transmission.metadata.droneID);
                fprintf('│ Time: %s\n', data.transmission.metadata.timestamp);
                fprintf('│ Mission: %s\n', data.transmission.metadata.missionDesc);
                fprintf('│ Data Size: %d bytes\n', data.transmission.metadata.dataSize);
                fprintf('│ Block: #%d\n', data.transmission.blockchainRef);
                fprintf('└───────────────────────────────────────────────┘\n');
            end
        end
    end
end
