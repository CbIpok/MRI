
function fileListGUI
    clear all
    % Создаем главное окно GUI с увеличенными размерами для нового функционала
    fig = uifigure('Name', 'GUI: Список файлов и масок', 'Position', [100, 100, 750, 500]);
    movegui(fig, 'center');
    
    % Три числовых поля для ввода размеров (x, y, z) для файла
    edt1 = uieditfield(fig, 'numeric', 'Position', [200, 360, 100, 22], 'Value', 0);
    edt2 = uieditfield(fig, 'numeric', 'Position', [200, 330, 100, 22], 'Value', 0);
    edt3 = uieditfield(fig, 'numeric', 'Position', [200, 300, 100, 22], 'Value', 0);
    
    % Список для файлов
    fileList = uilistbox(fig, ...
        'Position', [50, 50, 400, 220], ...
        'MultiSelect', 'on', ...
        'Items', {});  % Изначально пустой
    
    % Кнопка "Открыть файл"
    btnOpenFile = uibutton(fig, 'push', ...
        'Text', 'Открыть файл', ...
        'Position', [200, 400, 100, 30], ...
        'ButtonPushedFcn', @(src, event) openFileCallback(edt1, edt2, edt3, fileList));
    
    % Кнопка "Отобразить элемент" для просмотра срезов выбранного файла
    btnDisplay = uibutton(fig, 'push', ...
        'Text', 'Отобразить элемент', ...
        'Position', [350, 400, 120, 30], ...
        'ButtonPushedFcn', @(src, event) displaySelectedCallback(fileList));
    
    % Кнопка "Просмотреть выбранные" для просмотра нескольких массивов
    btnDisplayMultiple = uibutton(fig, 'push', ...
        'Text', 'Просмотреть выбранные', ...
        'Position', [10, 400, 150, 30], ...
        'ButtonPushedFcn', @(src, event) displayMultipleCallback(fileList));
    
    % Новые элементы для сегментации выбранного слоя:
    % Числовое поле для ввода номера слоя для сегментации
    lblSlice = uilabel(fig, 'Text', 'Номер слоя:', 'Position', [470, 360, 80, 22]);
    sliceField = uieditfield(fig, 'numeric', ...
        'Position', [550, 360, 50, 22], ...
        'Value', 1, ...
        'Limits', [1 Inf], 'RoundFractionalValues', true);
    
    
    % Список для масок
    maskList = uilistbox(fig, ...
        'Position', [470, 50, 250, 280], ...
        'MultiSelect', 'on', ...
        'Items', {});  % Изначально пустой

     % Кнопка для передачи выбранного слоя в Image Segmenter
    btnSegment = uibutton(fig, 'push', ...
        'Text', 'Segment Layer', ...
        'Position', [610, 355, 120, 30], ...
        'ButtonPushedFcn', @(src, event) segmentLayerCallback(fileList, sliceField, maskList));
end
