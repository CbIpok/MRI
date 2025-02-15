function fileListGUI
    % Создаем окно GUI с заданной позицией и размерами
    fig = uifigure('Name', 'GUI: Список файлов', 'Position', [100, 100, 500, 450]);
    movegui(fig, 'center');
    
    % Три числовых поля для ввода размеров (x, y, z)
    edt1 = uieditfield(fig, 'numeric', 'Position', [200, 360, 100, 22], 'Value', 0);
    edt2 = uieditfield(fig, 'numeric', 'Position', [200, 330, 100, 22], 'Value', 0);
    edt3 = uieditfield(fig, 'numeric', 'Position', [200, 300, 100, 22], 'Value', 0);
    
    % Создаем список для элементов (с поддержкой множественного выбора)
    listBox = uilistbox(fig, ...
        'Position', [50, 50, 400, 220], ...
        'MultiSelect', 'on', ...
        'Items', {});  % Изначально список пустой
    
    
    % Добавляем кнопку "Отобразить элемент" для показа срезов выбранного массива
    btnDisplay = uibutton(fig, 'push', ...
        'Text', 'Отобразить элемент', ...
        'Position', [350, 400, 120, 30], ...
        'ButtonPushedFcn', @(src, event) displaySelectedCallback(listBox));
    
    % Создаем кнопку "Открыть файл" (функция openFileCallback уже реализована отдельно)
    btnOpenFile = uibutton(fig, 'push', ...
        'Text', 'Открыть файл', ...
        'Position', [200, 400, 100, 30], ...
        'ButtonPushedFcn', @(src, event) openFileCallback(edt1, edt2, edt3, listBox));

     % Кнопка для отображения выбранных элементов (несколько массивов)
    btnDisplayMultiple = uibutton(fig, 'push', ...
        'Text', 'Просмотреть выбранные', ...
        'Position', [10, 400, 150, 30], ...
        'ButtonPushedFcn', @(src, event) displayMultipleCallback(listBox));
end
