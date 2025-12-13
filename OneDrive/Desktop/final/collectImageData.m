function imageData = collectImageData()
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', ...
        'Image Files (*.jpg, *.png, *.bmp, *.tif)'}, 'Select an Image File');
    
    if isequal(filename, 0)
        fprintf('No file selected. Generating random image data...\n');
        imageData.type = 'random_image';
        imageData.data = randi([0 255], 640, 480, 3, 'uint8');
        imageData.filename = 'random_image.jpg';
    else
        fprintf('Loading image: %s\n', filename);
        img = imread(fullfile(pathname, filename));
        imageData.type = 'user_image';
        imageData.data = img;
        imageData.filename = filename;
        imageData.filepath = fullfile(pathname, filename);
        
        figure('Name', 'User Selected Image');
        imshow(img);
        title(sprintf('Image to Transmit: %s', filename));
    end
    
    promptMeta = {'Enter target classification (e.g., vehicle, person, building):', ...
                  'Enter confidence score (0-1):', ...
                  'Enter priority level (1-5):'};
    titleMeta = 'Image Metadata';
    dimsMeta = [1 50];
    defaultMeta = {'unclassified', '0.85', '3'};
    
    answerMeta = inputdlg(promptMeta, titleMeta, dimsMeta, defaultMeta);
    
    if ~isempty(answerMeta)
        imageData.classification = answerMeta{1};
        imageData.confidence = str2double(answerMeta{2});
        imageData.priority = str2double(answerMeta{3});
    else
        imageData.classification = 'unclassified';
        imageData.confidence = 0.85;
        imageData.priority = 3;
    end
end
