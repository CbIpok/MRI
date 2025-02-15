function displayMultipleCallback(listBox)
    % Получаем выбранные элементы из списка
    selectedItems = listBox.Value;
    if isempty(selectedItems)
        uialert(listBox.Parent, 'Не выбран ни один элемент.', 'Ошибка');
        return;
    end
    if ~iscell(selectedItems)
        selectedItems = {selectedItems};
    end
    numArrays = numel(selectedItems);
    
    % Инициализация массивов и имён
    arrays = cell(1, numArrays);
    names  = cell(1, numArrays);
    
    % Вычисляем глобальный минимум и максимум для единых границ colormap
    globalMin = inf;
    globalMax = -inf;
    
    % Извлекаем массивы из базового рабочего пространства по именам переменных
    for i = 1:numArrays
        % Ожидаемый формат: "имя_файла [x, y, z]"
        tokens = strsplit(selectedItems{i}, ' ');
        fileNameWithExt = tokens{1};
        [varName, ~, ~] = fileparts(fileNameWithExt);
        varName = fileNameWithExt;
        names{i} = varName;
        try
            arr = evalin('base', varName);
        catch
            uialert(listBox.Parent, ['Переменная "', varName, '" не найдена в базовом рабочем пространстве.'], 'Ошибка');
            return;
        end
        arrays{i} = arr;
        globalMin = min(globalMin, min(arr(:)));
        globalMax = max(globalMax, max(arr(:)));
    end
    
    % Определяем максимальное число срезов среди выбранных массивов
    maxSlices = 0;
    for i = 1:numArrays
        [~, ~, zDim] = size(arrays{i});
        maxSlices = max(maxSlices, zDim);
    end
    
    %% Создаем окно просмотра
    viewFig = uifigure('Name', 'Просмотр нескольких массивов', 'Position', [100 100 800 600]);
    movegui(viewFig, 'center');
    
    % Зона для элементов управления (панель внизу)
    controlPanelHeight = 100;
    ctrlPanel = uipanel(viewFig, 'Position', [0, 0, viewFig.Position(3), controlPanelHeight]);
    
    % Панель для осей (отображения срезов)
    axesPanel = uipanel(viewFig, 'Position', [0, controlPanelHeight, viewFig.Position(3), viewFig.Position(4)-controlPanelHeight]);
    
    %% Элементы управления: текстовое поле и кнопка для задания количества картинок по горизонтали
    defaultNumCols = 3;
    lbl = uilabel(ctrlPanel, 'Position', [20, 70, 180, 22], 'Text', 'Картинок по горизонтали:');
    numColsField = uieditfield(ctrlPanel, 'numeric', ...
        'Position', [200, 70, 80, 22], ...
        'Value', defaultNumCols, ...
        'Limits', [1 Inf], ...
        'RoundFractionalValues', true);
    applyButton = uibutton(ctrlPanel, 'push', ...
        'Text', 'Применить', ...
        'Position', [300, 70, 100, 22], ...
        'ButtonPushedFcn', @(src,event) applyLayout());
    
    % Ползунок для выбора первого отображаемого среза (одинаков для всех массивов)
    sliderControl = uislider(ctrlPanel, ...
        'Position', [20, 30, viewFig.Position(3)-40, 3], ...
        'Limits', [1, maxSlices], ...
        'Value', 1);
    sliderControl.ValueChangedFcn = @(sld,event) updateSlices(round(sld.Value));
    
    %% Переменные для хранения информации о расположении осей
    % axesHandles - ячейка размера [numArrays x numCols]
    axesHandles = {};
    numCols = defaultNumCols; % текущее число изображений по горизонтали
    
    % Функция для создания/пересоздания разметки осей на панели
    function createAxesLayout()
        % Удаляем все предыдущие оси из панели
        delete(axesPanel.Children);
        
        panelWidth = axesPanel.Position(3);
        panelHeight = axesPanel.Position(4);
        
        % Для каждого массива (строка) создаём numCols осей (столбцы)
        rowHeight = panelHeight / numArrays;
        colWidth  = panelWidth / numCols;
        axesHandles = cell(numArrays, numCols);
        for i = 1:numArrays
            for j = 1:numCols
                left = (j-1)*colWidth;
                bottom = panelHeight - i*rowHeight;
                pos = [left, bottom, colWidth, rowHeight];
                axesHandles{i,j} = uiaxes(axesPanel, 'Position', pos, 'XTick', [], 'YTick', []);
            end
        end
        
        % После создания разметки обновляем изображения
        updateSlices(round(sliderControl.Value));
    end

    % Функция обновления отображаемых срезов для всех массивов
    % startSlice - индекс первого среза для отображения в каждом ряду
    function updateSlices(startSlice)
        for i = 1:numArrays
            [~, ~, zDim] = size(arrays{i});
            for j = 1:numCols
                sliceIndex = startSlice + j - 1;
                if sliceIndex > zDim
                    sliceIndex = zDim; % если индекс превышает число срезов, берем последний
                end
                ax = axesHandles{i,j};
                imagesc(ax, arrays{i}(:,:,sliceIndex), [globalMin, globalMax]);
                colormap(ax, jet);
                title(ax, sprintf('%s (z = %d)', names{i}, sliceIndex));
                ax.XTick = [];
                ax.YTick = [];
            end
        end
    end

    % Callback кнопки "Применить" - пересоздание разметки с новым числом колонок
    function applyLayout()
        numCols = round(numColsField.Value);
        if numCols < 1
            numCols = 1;
        end
        createAxesLayout();
    end

    % Изначально создаем разметку с числом колонок по умолчанию
    createAxesLayout();
end
