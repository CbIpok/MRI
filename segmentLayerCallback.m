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
    
    % Ожидается формат: "имя_файла [x, y, z]"
    tokens = strsplit(selectedStr, ' ');
    fileNameWithExt = tokens{1};
    [varName, ~, ~] = fileparts(fileNameWithExt);
    varName = fileNameWithExt;

    % Получаем 3D-массив из рабочего пространства
    try
        array3D = evalin('base', varName);
    catch
        uialert(fileList.Parent, ...
            ['Переменная "', varName, '" не найдена в базовом рабочем пространстве.'], ...
            'Ошибка');
        return;
    end
    
    % Проверяем корректность номера слоя
    sliceNumber = round(sliceField.Value);
    [~, ~, zDim] = size(array3D);
    if sliceNumber < 1 || sliceNumber > zDim
        uialert(fileList.Parent, sprintf('Номер слоя должен быть в диапазоне [1, %d].', zDim), 'Ошибка');
        return;
    end
    
    % Извлекаем указанный слой (2D-срез)
    sliceImage = array3D(:,:,sliceNumber);
    
    % Запускаем Image Segmenter с выбранным срезом
    imageSegmenter(sliceImage);
    
    % Если таймер для обновления масок ещё не запущен, создаём и запускаем его
    existingTimers = timerfind('Tag', 'MaskTimer');
    if isempty(existingTimers)
        t = timer('ExecutionMode', 'fixedRate', ...
                  'Period', 1, ...           % обновление каждую секунду
                  'TimerFcn', @updateMaskList, ...
                  'Tag', 'MaskTimer');
        start(t);
        disp('Запущен таймер для постоянного обновления списка масок.');
    end

    % Вложенная функция для обновления списка масок
    function updateMaskList(~,~)
        % Получаем все 2D-логические переменные из рабочего пространства
        newMasks = get2DLogicalVarNames();
        % Обновляем список масок в главном окне
        maskList.Items = newMasks;
    end

    % Вспомогательная функция для получения имен всех 2D-логических переменных
    function varNames = get2DLogicalVarNames()
        info = evalin('base', 'whos');
        varNames = {};
        for i = 1:numel(info)
            if strcmp(info(i).class, 'logical') && numel(info(i).size) == 2
                varNames{end+1} = info(i).name; %#ok<AGROW>
            end
        end
    end
end
