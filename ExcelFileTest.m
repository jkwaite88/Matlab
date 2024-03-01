Excel = actxserver('Excel.Application');
excelWorkbook = Excel.workbooks.Open('C:\Users\jwaite\OneDrive - Wavetronix LLC\Data\DataLogger\2021-01-31\events.xlsx');
Excel.visible = true; % Make Excel appear so we can see it, otherwise it is hidden.
Excel.ActiveWorkbook.Save();
excelWorkbook.Close(false);
Excel.Quit;
