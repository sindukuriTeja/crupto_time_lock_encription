function textData = collectTextData()
    prompt = {'Enter reconnaissance report or text data:'};
    dlgtitle = 'Text Data Input';
    dims = [10 80];
    definput = {'Surveillance report: Target detected at coordinates. No hostile activity observed. Weather conditions: Clear. Recommend continued monitoring.'};
    
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    if isempty(answer)
        textData.type = 'text';
        textData.data = 'Default reconnaissance report';
    else
        textData.type = 'text';
        textData.data = answer{1};
    end
    
    textData.wordCount = length(strsplit(textData.data));
    fprintf('Text data collected: %d words\n', textData.wordCount);
end
