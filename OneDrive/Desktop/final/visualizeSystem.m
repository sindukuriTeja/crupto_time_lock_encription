function visualizeSystem(drone, groundStation, missionData)
    figure('Position', [100 100 1200 600], 'Name', 'Secure Drone Transmission System');
    
    subplot(1,2,1);
    plot(drone.location(2), drone.location(1), 'ro', 'MarkerSize', 20, ...
        'LineWidth', 3, 'MarkerFaceColor', 'r');
    hold on;
    plot(groundStation.location(2), groundStation.location(1), 'bs', ...
        'MarkerSize', 20, 'LineWidth', 3, 'MarkerFaceColor', 'b');
    plot([drone.location(2), groundStation.location(2)], ...
         [drone.location(1), groundStation.location(1)], ...
         'g--', 'LineWidth', 2);
    
    text(drone.location(2), drone.location(1)+1, ...
        sprintf('  %s\n  [%.4f, %.4f]', drone.droneID, ...
        drone.location(1), drone.location(2)), 'FontSize', 9);
    text(groundStation.location(2), groundStation.location(1)-1, ...
        sprintf('  %s\n  [%.4f, %.4f]', groundStation.stationID, ...
        groundStation.location(1), groundStation.location(2)), 'FontSize', 9);
    
    xlabel('Longitude', 'FontSize', 12);
    ylabel('Latitude', 'FontSize', 12);
    title('Cross-Border Secure Data Transmission', 'FontSize', 14, 'FontWeight', 'bold');
    legend('Drone (Foreign)', 'Ground Station (India)', 'Encrypted Channel', ...
        'Location', 'best');
    grid on;
    
    subplot(1,2,2);
    if ~isempty(drone.blockchainLedger)
        blockNumbers = 1:length(drone.blockchainLedger);
        blockHashes = arrayfun(@(x) x.hash, drone.blockchainLedger);
        
        bar(blockNumbers, blockHashes/1e9, 'FaceColor', [0.2 0.6 0.8]);
        xlabel('Block Number', 'FontSize', 12);
        ylabel('Block Hash (×10^9)', 'FontSize', 12);
        title('Blockchain Ledger', 'FontSize', 14, 'FontWeight', 'bold');
        grid on;
        
        for i = 1:length(blockNumbers)
            text(i, blockHashes(i)/1e9, sprintf('  #%d', i), ...
                'FontSize', 8, 'VerticalAlignment', 'bottom');
        end
    end
end
