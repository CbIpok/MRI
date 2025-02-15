function segmentLayerCallback(fileList, sliceField, maskList)
    % Получаем выбранный элемент из списка файлов
    selectedItems = fileList.Value;
    if isempty(selectedItems)
        uialert(fileList.Parent, 'Не выбран ни один файл.', 'Ошибка');
        return;
    end
    if iscell(selectedItems)
        selectedStr = selectedItems{1};
    else
        selectedStr = selectedItems;
    end
    
    % Ожидаемый формат: "имя_файла [x, y, z]"
    % Извлекаем имя файла (до первого пробела) и получаем имя переменной без расширения
    tokens = strsplit(selectedStr, ' ');
    fileNameWithExt = tokens{1};
    [varName, ~, ~] = fileparts(fileNameWithExt);
    varName = fileNameWithExt;
    
    % Получаем 3D-массив из базового рабочего пространства
    try
        array3D = evalin('base', varName);
    catch
        uialert(fileList.Parent, ['Переменная "', varName, '" не найдена в базовом рабочем пространстве.'], 'Ошибка');
        return;
    end
    
    % Получаем номер слоя из текстового поля
    sliceNumber = round(sliceField.Value);
    [~, ~, zDim] = size(array3D);
    if sliceNumber < 1 || sliceNumber > zDim
        uialert(fileList.Parent, sprintf('Номер слоя должен быть в диапазоне [1, %d].', zDim), 'Ошибка');
        return;
    end
    
    % Извлекаем изображение выбранного слоя
    sliceImage = array3D(:,:,sliceNumber);
    
    % Запускаем Image Segmenter с выбранным срезом
    segApp = imageSegmenter(sliceImage);
    
    % Блокируем выполнение до закрытия окна Image Segmenter.
    % (Предполагается, что приложение возвращает handle с полем UIFigure)
    uiwait(segApp.UIFigure);
    
    % После закрытия Image Segmenter пытаемся получить экспортированную маску.
    % Пользователь должен экспортировать маску с именем "exportedMask".
    try
        mask = evalin('base', 'exportedMask');
    catch
        uialert(fileList.Parent, 'Маска не найдена в рабочем пространстве. Убедитесь, что вы экспортировали маску с именем "exportedMask".', 'Ошибка');
        return;
    end
    
    % Добавляем описание маски в список масок.
    newMaskItem = sprintf('%s (слой %d)', varName, sliceNumber);
    currentItems = maskList.Items;
    if isempty(currentItems)
        currentItems = {newMaskItem};
    else
        currentItems{end+1} = newMaskItem;
    end
    maskList.Items = currentItems;
    
    % Можно сохранить маску в структуре maskData в базовом рабочем пространстве для дальнейшего использования
    try
        maskData = evalin('base', 'maskData');
    catch
        maskData = struct();
    end
    fieldName = matlab.lang.makeValidName(newMaskItem);
    maskData.(fieldName) = mask;
    assignin('base', 'maskData', maskData);
    
    % Вывод сообщения в командное окно
    disp(['Маска для ', newMaskItem, ' добавлена в список.']);
end
