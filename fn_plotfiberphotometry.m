  function [datatosave] = fn_plotfiberphotometry(folder, minutesbaseline, minutespost, toplotornot)
    % FN_PLOTFIBERPHOTOMETRY processes fiber photometry data and plots individual and group traces.
    
    % USAGE:
    %   datatosave = fn_plotfiberphotometry(folder, minutesbaseline, minutespost, toplotornot)
    %
    % INPUTS:
    %   folder           = path to folder containing .csv trace files and subfolder with TTLs 'time_admin_files'
    %   minutesbaseline  = number of minutes before drug/saline  administration
    %                      (1) min baseline can be used as default 
    %   minutespost      = number of minutes after administration
    %                      (19) min post injection can be used as default
    %   toplotornot      = 1 to plot individual and average traces, 0 to skip plotting
    %
    % OUTPUT:
    %   datatosave       = struct with time vector, normalized traces, AUCs, and per-minute data
    

    tic
    minutespostB = minutespost + 0.1;
    colorWT = [64,64,64; 115,166,173] ./ 255;  % grey and teal

    folderB = fullfile(folder, 'time_admin_files');
    files = struct2table(dir(fullfile(folder, '*.csv')));
    filesB = struct2table(dir(fullfile(folderB, '*.csv')));
    totalRats = height(files);

    iwant = erase(files.name, '.csv');
    iwantB = erase(filesB.name, '.csv');

    timestampB = zeros(2000000, totalRats);
    signalSaline = [];
    signalDrug = [];

    AUC_salino = zeros(1, totalRats);
    AUC_drug = zeros(1, totalRats);
    AUC_salino10 = zeros(1, totalRats);
    AUC_drug10 = zeros(1, totalRats);
    AUC_salinoNorm = zeros(1, totalRats);
    AUC_drugNorm = zeros(1, totalRats);
    AUC_salino10Norm = zeros(1, totalRats);
    AUC_drug10Norm = zeros(1, totalRats);

    perminAUC = zeros(minutesbaseline + minutespost, totalRats);
    perminAUCDrug = zeros(minutesbaseline + minutespost, totalRats);

    for iRat = 1:totalRats
        dataFile = fullfile(folder, [iwant{iRat}, '.csv']);
        timeFile = fullfile(folderB, [iwantB{iRat}, '.csv']);

        data = readtable(dataFile, 'NumHeaderLines', 1);
        timeAdmin = readtable(timeFile, 'NumHeaderLines', 1);

        timeVec = data{:, 1};
        signalRaw = data{:, 2};
        timestampB(1:length(timeVec), iRat) = timeVec;

        timeSaline = timeAdmin{1, 2};
        timeDrug = timeAdmin{2, 2};

        [~, frameSaline] = min(abs(round(timeVec, 4) - timeSaline));
        [~, frameDrug] = min(abs(round(timeVec, 4) - timeDrug));

        dt = (timeVec(end) - timeVec(1)) / length(timeVec);
        nbPre = round(60 * minutesbaseline / dt);
        nbPost = round(60 * minutespostB / dt);
        nbPost10 = round(60 * 10 / dt);
        nbPerMin = round(60 / dt);

        sigSal = signalRaw(frameSaline - nbPre : frameSaline + nbPost);
        sigDrug = signalRaw(frameDrug - nbPre : frameDrug + nbPost);

        baselineSal = mean(sigSal(1:nbPre));
        baselineDrug = mean(sigDrug(1:nbPre));

        corrSal = sigSal - baselineSal;
        corrDrug = sigDrug - baselineDrug;

        signalSaline(:, iRat) = corrSal;
        signalDrug(:, iRat) = corrDrug;

        AUC_salino(iRat) = trapz(corrSal(nbPre+1:end));
        AUC_drug(iRat) = trapz(corrDrug(nbPre+1:end));
        AUC_salino10(iRat) = trapz(corrSal(nbPre+1:nbPre+nbPost10));
        AUC_drug10(iRat) = trapz(corrDrug(nbPre+1:nbPre+nbPost10));

        AUC_salinoNorm(iRat) = trapz(corrSal(nbPre+1:end));
        AUC_drugNorm(iRat) = trapz(corrDrug(nbPre+1:end));
        AUC_salino10Norm(iRat) = trapz(corrSal(nbPre+1:nbPre+nbPost10));
        AUC_drug10Norm(iRat) = trapz(corrDrug(nbPre+1:nbPre+nbPost10));

        perminAUC(:, iRat) = fn_getMeasureByMin(minutesbaseline, minutespost, nbPerMin, corrSal, 'AUC');
        perminAUCDrug(:, iRat) = fn_getMeasureByMin(minutesbaseline, minutespost, nbPerMin, corrDrug, 'AUC');
    end

    time = (-minutesbaseline*60 : dt : minutespostB*60) ./ 60;

    if toplotornot == 1
        for iRat = 1:totalRats
            figure()
            allval = [signalSaline(:, iRat); signalDrug(:, iRat)];
            minval = min(allval) - 0.05;
            maxval = max(allval) + 0.05;

            subplot(3,1,1); hold on;
            plot(time, signalSaline(:, iRat), 'Color', colorWT(1,:), 'LineWidth', 1);
            title([iwant{iRat}, ' Saline']); ylabel('Z score'); xline(0);
            ylim([minval, maxval]); xlim([-minutesbaseline, minutespost]);
            set(gca, 'TickDir', 'in', 'FontSize', 12, 'FontName', 'Arial');

            subplot(3,1,2); hold on;
            plot(time, signalDrug(:, iRat), 'Color', colorWT(2,:), 'LineWidth', 1);
            title([iwant{iRat}, ' Drug']); ylabel('Z score'); xline(0);
            ylim([minval, maxval]); xlim([-minutesbaseline, minutespost]);
            set(gca, 'TickDir', 'out', 'FontSize', 12, 'FontName', 'Arial');

            subplot(3,1,3); hold on;
            plot(time, signalSaline(:, iRat), 'Color', colorWT(1,:), 'LineWidth', 1);
            plot(time, signalDrug(:, iRat), 'Color', colorWT(2,:), 'LineWidth', 1);
            title(iwant{iRat}); ylabel('Z score'); xline(0);
            ylim([minval, maxval]); xlim([-minutesbaseline, minutespost]);
            set(gca, 'TickDir', 'out', 'FontSize', 12, 'FontName', 'Arial');
        end

        figure(); hold on;
        shadedErrorBar(time, mean(signalSaline, 2), std(signalSaline')/sqrt(totalRats), ...
            'lineProps', {'Color', colorWT(1,:), 'LineWidth', 1});
        shadedErrorBar(time, mean(signalDrug, 2), std(signalDrug')/sqrt(totalRats), ...
            'lineProps', {'Color', colorWT(2,:), 'LineWidth', 1});
        title('All Rats'); ylabel('Z score'); xlabel('Time (min)'); xline(0);
        ylim([-2.5, 2.5]); xlim([-minutesbaseline, 20]);
        set(gca, 'TickDir', 'out', 'FontSize', 12, 'FontName', 'Arial');
    end

    datatosave.time = time;
    datatosave.saline = signalSaline;
    datatosave.cocaine = signalDrug;
    datatosave.AUCsaline = AUC_salino;
    datatosave.AUCcocaine = AUC_drug;
    datatosave.AUCsalineNorm = AUC_salinoNorm;
    datatosave.AUC_drugNorm = AUC_drugNorm;
    datatosave.AUC_salino10Norm = AUC_salino10Norm;
    datatosave.AUC_drug10Norm = AUC_drug10Norm;
    datatosave.perminAUC = perminAUC;
    datatosave.perminAUCDrug = perminAUCDrug;

    toc
end
