function processedData = processUserData(userInputs)
    switch userInputs.type
        case {'user_image', 'random_image'}
            processedData = uint8(userInputs.data(:));
            fprintf('Image processed: %d bytes\n', length(processedData));
            
        case 'text'
            processedData = uint8(userInputs.data);
            fprintf('Text processed: %d bytes\n', length(processedData));
            
        otherwise
            processedData = uint8(randi([0 255], 1000, 1));
    end
end
