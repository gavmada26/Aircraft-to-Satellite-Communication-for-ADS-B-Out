


function gui()
%% Initializare GUI
    fig = figure('Name', 'GUI ADS-B OUT', ...
                   'Position', [100 100 750 850], ...
                   'MenuBar', 'figure', ...
                   'NumberTitle', 'off', ...
                   'Color', [0.25 0.25 0.25]);
    buttonHeight = 0.07;
    buttonWidth = 0.45;
    spacingX = 0.03;
    spacingY = 0.02;
    startXLeft = 0.03;
    startXRight = startXLeft + buttonWidth + spacingX;
    fontSize = 14;
    buttonColor = [0 1 0];
    numRows = 9;
    totalHeight = (numRows * buttonHeight) + ((numRows - 1) * spacingY) + 0.05;
    panelHeight = totalHeight + 0.10;
    panelY = (1 - panelHeight) / 2;
    mainPanel = uipanel(fig, 'Title', 'MENIU INTERFATA', ...
                         'Position', [0.02, panelY + 0.05, 0.96, panelHeight - 0.05], ...
                         'BackgroundColor', [0.94 0.94 0.94], ...
                         'BorderType', 'etchedout', ...
                         'FontWeight', 'bold', ...
                         'FontSize', 14);
    currentY = 1 - 0.25;
    sc = [];
    viewer = [];
    airports = [];
    trajectory = [];
    aircraft = [];
    iridiumSatellites = [];
    acAirport = [];
    acSatellite = [];
    aircraftADSBTransmitter = [];
    airportADSBReceiver = [];
    satelliteADSBReceiver = [];
    lnkADSB = [];
    antennaDropdown = [];
    fADSB = 1090e6;
    playButton = uicontrol(fig, 'Style', 'pushbutton', ...
                             'Units', 'normalized', ...
                             'Position', [0.3, 0.90, 0.4, 0.05], ...
                             'String', 'Start Simulare 3D', ...
                             'FontSize', fontSize, ...
                             'BackgroundColor', [0 1 0], ...
                             'UserData', 0, ...
                             'Callback', @togglePlayback);
%% Functii Utilitare Locale
    function displayMessage(message)
        disp(message);
    end
    function runSection(sectionNumber, src, event)
        try
            disp(['Ruleaza sectiunea: ', num2str(sectionNumber)]);
            switch sectionNumber
                case 1, createScenarioViewer();
                case 2, createAirports();
                case 3, createAircraftTrajectory();
                case 4, createAircraft();
                case 5, createIridiumSatellites();
                case 6, analyzeAircraftAirportAccess();
                case 7, analyzeAircraftSatelliteAccess();
                case 8, plotSatelliteVisibility();
                case 9, configureAircraftADSBTransmitter();
                case 10, configureAirportADSBReceivers();
                case 11, configureSatelliteAntennaCallback(src, event);
                case 12, analyzeADSBLink();
                case 13, playScenario();
                case 14, displaySatelliteAntennaPattern(src, event);
            end
        catch ME
            warning(['Eroare la rularea sectiunii ', num2str(sectionNumber), ': ', ME.message]);
            displayMessage(['Eroare: ', ME.message]);
        end
    end
    function togglePlayback(src, event)
        isPlaying = get(src, 'UserData');
        if isempty(viewer) || ~isvalid(viewer) || isempty(sc) || ~isvalid(sc)
            displayMessage('Scenariul si vizualizatorul 3D trebuie create mai intai.');
            return;
        end
        if isPlaying == 0
            set(src, 'String', 'Stop Simulare 3D');
            set(src, 'UserData', 1);
            viewer.PlaybackSpeedMultiplier = 5;
            if isvalid(aircraft)
                camtarget(viewer, aircraft);
            end
            play(sc);
            displayMessage('Simulare 3D pornita.');
        else
            set(src, 'String', 'Start Simulare 3D');
            set(src, 'UserData', 0);
            stop(sc);
            displayMessage('Simulare 3D oprita.');
        end
    end

%% Crearea Elementelor GUI
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth, buttonHeight], ...
              'String', 'Creaza Scenariu si Vizualizator', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(1, src, event));
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXRight, currentY, buttonWidth, buttonHeight], ...
              'String', 'Creaza Aeroporturi', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(2, src, event));
    currentY = currentY - (buttonHeight + spacingY);
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth, buttonHeight], ...
              'String', 'Creaza Traiectorie si Afisare Harta', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(3, src, event));
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXRight, currentY, buttonWidth, buttonHeight], ...
              'String', 'Creaza Aeronava', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(4, src, event));
    currentY = currentY - (buttonHeight + spacingY);
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth, buttonHeight], ...
              'String', 'Creaza Sateliti Iridium', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(5, src, event));
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXRight, currentY, buttonWidth, buttonHeight], ...
              'String', 'Analiza Acces Aeronava-Aeroport', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(6, src, event));
    currentY = currentY - (buttonHeight + spacingY);
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth, buttonHeight], ...
              'String', 'Analiza Acces Aeronava-Sateliti', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(7, src, event));
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXRight, currentY, buttonWidth, buttonHeight], ...
              'String', 'Plotare Vizibilitate Sateliti', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(8, src, event));
    currentY = currentY - (buttonHeight + 2 * spacingY);
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth, buttonHeight], ...
              'String', 'Configurare Transmitator ADS-B Aeronava', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(9, src, event));
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXRight, currentY, buttonWidth, buttonHeight], ...
              'String', 'Configurare Receptori ADS-B Aeroporturi', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(10, src, event));
    currentY = currentY - (buttonHeight + spacingY);
    uicontrol(mainPanel, 'Style', 'text', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth * 0.4, buttonHeight], ...
              'String', 'Tip Antena Satelit:', ...
              'HorizontalAlignment', 'left', ...
              'FontSize', fontSize);


    antennaTypes = ["Isotropic", "Custom Omni-Azimuth", "Custom DonutPattern", "Custom DualLobe"];
    antennaDropdown = uicontrol(mainPanel, 'Style', 'popupmenu', ...
                                'Units', 'normalized', ...
                                'Position', [startXLeft + buttonWidth * 0.4 + spacingX / 4, currentY, buttonWidth * 0.55, buttonHeight], ...
                                'String', antennaTypes, ...
                                'Value', 1, ...
                                'FontSize', fontSize, ...
                                'BackgroundColor', [0.9 0.9 0.9]);


    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXRight, currentY, buttonWidth, buttonHeight], ...
              'String', 'Configureaza Receptori ADS-B Sateliti', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(11, src, event));
    currentY = currentY - (buttonHeight + spacingY);
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth, buttonHeight], ...
              'String', 'Afiseaza Diagrama Antena Satelit', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(14, src, event));
    currentY = currentY - (buttonHeight + spacingY);
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXLeft, currentY, buttonWidth, buttonHeight], ...
              'String', 'Analiza Legatura ADS-B', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(12, src, event));
    uicontrol(mainPanel, 'Style', 'pushbutton', ...
              'Units', 'normalized', ...
              'Position', [startXRight, currentY, buttonWidth, buttonHeight], ...
              'String', 'Redare Scenariu 3D', ...
              'FontSize', fontSize, ...
              'BackgroundColor', buttonColor, ...
              'Callback', @(src,event) runSection(13, src, event));
    currentY = currentY - (buttonHeight + 2 * spacingY);
    helpButtonSize = 0.06;
    helpButton = uicontrol(fig, 'Style', 'pushbutton', ...
                                 'Units', 'normalized', ...
                                 'Position', [0.94, 0.94, helpButtonSize, helpButtonSize], ...
                                 'String', '?', ...
                                 'FontSize', 24, ...
                                 'FontWeight', 'bold', ...
                                 'TooltipString', 'Deschide documentatia de ajutor', ...
                                 'BackgroundColor', [0.8 0.8 0.8], ...
                                 'Callback', @openHelpDocument);



%% Functiile de Callback ale Butoanelor
    function createScenarioViewer()
        startTime = datetime("now", "TimeZone", "Europe/Bucharest");
        stopTime = startTime + hours(10) + minutes(19);
        sampleTime = 10;
        sc = satelliteScenario(startTime,stopTime,sampleTime);
        viewer = satelliteScenarioViewer(sc);
        assignin('base', 'sc', sc);
        assignin('base', 'viewer', viewer);
        viewerFigHandle = findobj('Type', 'figure', 'Tag', 'SatelliteScenarioViewerFigure');
        if isempty(viewerFigHandle)
            viewerFigHandle = findobj('Type', 'figure', 'Name', 'Satellite Scenario Viewer');
        end
        if isvalid(viewerFigHandle)
            set(viewerFigHandle, 'Visible', 'on');
            figure(viewerFigHandle);
        else
            displayMessage('Avertisment: Fereastra vizualizatorului nu a putut fi gasita. Asigurati-va ca este deschisa.');
        end
        displayMessage('Scenariu si vizualizator create.');
    end



    function createAirports()
        if ~isempty(sc)
            airportName = ["JFK International Airport (New York)"; "Avram Iancu International Airport (Cluj-Napoca)"];
            airportLat = [40.641766; 46.7830730254449];
            airportLon = [-73.780968; 23.687883979968024];
            airports = groundStation(sc,airportLat,airportLon,Name=airportName);
            assignin('base', 'airports', airports);
            displayMessage('Aeroporturi create.');
        else
            displayMessage('Scenariul trebuie creat mai intai.');
        end
    end





    function createAircraftTrajectory()
        if ~isempty(sc)
waypoints = [...
    40.656525, -73.787485, 3;...
    40.654970, -73.784175, 10;...
    40.654152, -73.782182, 50;...
    40.652117, -73.777955, 70;...
    40.650567, -73.774214, 200;...
    40.648000, -73.770000, 400;...
    40.645000, -73.765000, 500;...
    40.700000, -73.700000, 700;...
    40.750000, -73.600000, 1000;...
    40.8000, -73.5000, 1500;...
    40.9000, -73.4000, 4000;...
    41.0000, -73.2000, 7000;...
    41.5000, -72.5000, 8000;...
    42.0000, -71.0000, 9000;...
    45.0000, -69.0000, 10500;...
    48.0000, -60.0000, 10900;...
    50.0000, -50.0000, 11000;...
    51.0000, -40.0000, 11270;...
    50.5000, -20.0000, 11270;...
    49.5000, -10.0000, 11270;...
    48.0000,   0.0000, 11270;...
    47.0000,  10.0000, 11270;...
    46.5000,  15.0000, 9000;...
    46.7000,  20.0000, 6000;...
    46.7500,  21.5000, 3000;...
    46.7800,  22.5000, 1500;...
    46.7830,  23.0000, 300;...
    46.7845,  23.5000, 100;...
    46.785142, 23.674468, 70;...
    46.786131, 23.678552, 10;...
    46.786952, 23.682050, 4];
            timeOfArrival = duration([...
                "00:00:00"; "00:00:30"; "00:01:30"; "00:02:30"; "00:03:30"; "00:04:30"; "00:05:30"; "00:07:00";
                "00:09:30"; "00:13:00"; "00:17:00"; "00:25:00"; "00:40:00"; "01:10:00"; "01:50:00"; "02:40:00";
                "03:40:00"; "04:50:00"; "06:10:00"; "07:40:00"; "08:30:00"; "09:10:00"; "09:40:00"; "10:00:00";
                "10:15:00"; "10:16:00"; "10:16:30"; "10:17:00"; "10:17:30"; "10:18:00"; "10:18:30"]);
            trajectory = geoTrajectory(waypoints,seconds(timeOfArrival),AutoPitch=true,AutoBank=true);
            LLA = lookupPose(trajectory,0:sc.SampleTime:max(seconds(timeOfArrival)));
            figure('Name', 'Traiectorie Aeronava pe Harta', 'NumberTitle', 'off');
            geoplot(LLA(:,1), LLA(:,2), "red");
            geolimits([30, 60], [-80, 40]);
            geobasemap topographic;
            assignin('base', 'trajectory', trajectory);
            displayMessage('Traiectorie creata si afisata pe harta.');
        else
            displayMessage('Scenariul trebuie creat mai intai.');
        end
    end



    function createAircraft()
        if ~isempty(sc) && ~isempty(trajectory) && ~isempty(viewer)
            aircraft = platform(sc,trajectory, Name="YR-UTCN1", Visual3DModel="NarrowBodyAirliner.glb");
            camtarget(viewer,aircraft);
            drawnow;
            assignin('base', 'aircraft', aircraft);
            displayMessage('Aeronava creata si camera setata sa o urmareasca.');
        else
            displayMessage('Scenariul, traiectoria si vizualizatorul trebuie create mai intai.');
        end
    end



    function createIridiumSatellites()
        if ~isempty(sc) && ~isempty(viewer)
            numSatellitesPerOrbitalPlane = 11;
            numOrbits = 6;
            orbitIdx = repelem(1:numOrbits,1,numSatellitesPerOrbitalPlane);
            planeIdx = repmat(1:numSatellitesPerOrbitalPlane,1,numOrbits);
            RAAN = 180*(orbitIdx-1)/numOrbits;
            trueanomaly = 360*(planeIdx-1 + 0.5*(mod(orbitIdx,2)-1))/numSatellitesPerOrbitalPlane;
            semimajoraxis = repmat((6371 + 780)*1e3,size(RAAN));
            inclination = repmat(86.4,size(RAAN));
            eccentricity = zeros(size(RAAN));
            argofperiapsis = zeros(size(RAAN));
            iridiumSatellites = satellite(sc,...
                semimajoraxis,eccentricity,inclination,RAAN,argofperiapsis,trueanomaly,...
                Name="Iridium " + string(1:66)');
            hide(iridiumSatellites.Orbit,viewer);
            show(iridiumSatellites(1:numSatellitesPerOrbitalPlane:end).Orbit,viewer);
            assignin('base', 'iridiumSatellites', iridiumSatellites);
            displayMessage('Constelatia de sateliti Iridium a fost creata.');
        else
            displayMessage('Scenariul si vizualizatorul trebuie create mai intai.');
        end
    end



    function analyzeAircraftAirportAccess()
        if ~isempty(sc) && ~isempty(aircraft) && ~isempty(airports)
            acAirport = access(aircraft,airports);
            airportAccessIntvls = accessIntervals(acAirport);
            assignin('base', 'acAirport', acAirport);
            displayMessage('Analiza accesului aeronava-aeroport realizata.');
            disp(airportAccessIntvls);
        else
            displayMessage('Scenariul, aeronava si aeroporturile trebuie create mai intai.');
        end
    end



    function analyzeAircraftSatelliteAccess()
        if ~isempty(sc) && ~isempty(aircraft) && ~isempty(iridiumSatellites)
            iridiumConicalSensors = conicalSensor(iridiumSatellites,"MaxViewAngle",125);
            acSatellite = access(aircraft,iridiumConicalSensors);
            satelliteAccessIntvls = accessIntervals(acSatellite);
            assignin('base', 'acSatellite', acSatellite);
            displayMessage('Analiza accesului aeronava-sateliti realizata.');
            disp(satelliteAccessIntvls);
        else
            displayMessage('Scenariul, aeronava si satelitii trebuie create mai intai.');
        end
    end




    function plotSatelliteVisibility()
        if ~isempty(acSatellite) && ~isempty(iridiumSatellites) && ~isempty(sc)
            [sSatellite,time] = accessStatus(acSatellite);
            satVisPlotData = double(sSatellite);
            satVisPlotData(satVisPlotData == false) = NaN;
            satVisPlotData = satVisPlotData + (0:numel(iridiumSatellites)-1)';
            figure('Name', 'Vizibilitate Satelit', 'NumberTitle', 'off');
            plot(time,satVisPlotData," .",Color="red")
                yticks(1:8:66)
                yticklabels(iridiumSatellites.Name(1:8:66))
            title("Vizibilitate Satelit")
            grid on
            xlabel("Timp");
                ylabel("Satelit");
                axis tight
                zoomStartTime = sc.StartTime + hours(2);
            zoomEndTime = zoomStartTime + hours(4);
            xlim([zoomStartTime, zoomEndTime]);
            displayMessage('Plotarea vizibilitatii satelitilor realizata.');
        else
            displayMessage('Analiza accesului aeronava-sateliti trebuie realizata mai intai.');
        end
    end




    function configureAircraftADSBTransmitter()
        if ~isempty(aircraft)
            aircraftADSBAntenna = arrayConfig("Size",[1 1]);
            aircraftADSBTransmitter = transmitter(aircraft, ...
                'Antenna', aircraftADSBAntenna, ...
                'Frequency', fADSB,...
                'Power', 10*log10(125),...
                'MountingLocation', [8,0,-2.7],...
                'Name', "ADS-B Aircraft Transmitter");
            assignin('base', 'aircraftADSBTransmitter', aircraftADSBTransmitter);
            displayMessage('Transmitatorul ADS-B al aeronavei a fost configurat.');
        else
            displayMessage('Aeronava trebuie creata mai intai.');
        end
    end




    function configureAirportADSBReceivers()
        if ~isempty(airports)
            airportADSBAntenna = arrayConfig("Size",[1 1]);
            airportADSBReceiver = receiver(...
                airports, ...
                'Antenna', airportADSBAntenna, ...
                'Name', airports.Name + " Receiver");
            assignin('base', 'airportADSBReceiver', airportADSBReceiver);
            displayMessage('Receptoarele ADS-B ale aeroporturilor au fost configurate.');
        else
            displayMessage('Aeroporturile trebuie create mai intai.');
        end
    end



    function configureSatelliteAntennaCallback(src, event)
        antennaIndex = get(antennaDropdown, 'Value');
        antennaTypes = get(antennaDropdown, 'String');
        if isstring(antennaTypes)
            antennaTypes = cellstr(antennaTypes);
        end

        antennaType = antennaTypes{antennaIndex};
        satelliteADSBAntenna = [];

        switch antennaType
            case "Isotropic"
                satelliteADSBAntenna = arrayConfig("Size",[1 1]);


            case "Custom Omni-Azimuth"
                azimuthGrid = -180:5:180;
                elevationGrid = -90:5:90;
                [AZ, EL] = meshgrid(azimuthGrid, elevationGrid);
                gaindB = 10 * cosd(EL).^2;
                patternPower = 10.^(gaindB/10);
                satelliteADSBAntenna = phased.CustomAntennaElement( ...
                    'AzimuthAngles', azimuthGrid, ...
                    'ElevationAngles', elevationGrid, ...
                    'MagnitudePattern', patternPower, ...
                    'PhasePattern', zeros(size(patternPower)) );


            case "Custom DonutPattern"
                azimuthGrid = -180:5:180;
                elevationGrid = -90:5:90;
                [AZ, EL] = meshgrid(azimuthGrid, elevationGrid);
                gaindB = 10 * sind(EL).^2;
                patternPower = 10.^(gaindB / 10);
                satelliteADSBAntenna = phased.CustomAntennaElement( ...
                    'AzimuthAngles', azimuthGrid, ...
                    'ElevationAngles', elevationGrid, ...
                    'MagnitudePattern', patternPower, ...
                    'PhasePattern', zeros(size(patternPower)) );


                
            case "Custom DualLobe"
                azimuthGrid = -180:5:180;
                elevationGrid = -90:5:90;
                [AZ, EL] = meshgrid(azimuthGrid, elevationGrid);
                gaindB = -((EL - 60).^2)/200 - ((EL + 60).^2)/200 + 6;
                patternPower = 10.^(gaindB / 10);
                satelliteADSBAntenna = phased.CustomAntennaElement( ...
                    'AzimuthAngles', azimuthGrid, ...
                    'ElevationAngles', elevationGrid, ...
                    'MagnitudePattern', patternPower, ...
                    'PhasePattern', zeros(size(patternPower)) );
        end


        if ~isempty(satelliteADSBAntenna)
            satelliteADSBReceiver = receiver(iridiumSatellites, ...
                'Antenna', satelliteADSBAntenna, ...
                'MountingAngles', [0,-90,0], ...
                'Name', iridiumSatellites.Name + " Receiver");
            assignin('base', 'satelliteADSBReceiver', satelliteADSBReceiver);
            displayMessage(['Receptoarele ADS-B ale satelitilor configurate cu antena de tip: ', antennaType]);
        else
            displayMessage('Eroare: Antena satelitului nu a putut fi configurata.');
        end
    end



    function displaySatelliteAntennaPattern(src, event)
        if ~isempty(satelliteADSBReceiver)
            antennaIndex = get(antennaDropdown, 'Value');
            antennaStrings = get(antennaDropdown, 'String');
            if isstring(antennaStrings)
                selectedAntennaType = char(antennaStrings(antennaIndex));
            else
                selectedAntennaType = antennaStrings{antennaIndex};
            end
            try
                figure('Name', "Diagrama de Radiatie Satelit (" + string(selectedAntennaType) + ")", 'NumberTitle', 'off');
                pattern(satelliteADSBReceiver, fADSB, Size=200000);
                displayMessage('Diagrama antenei satelitului afisata.');
            catch ME_pattern
                displayMessage(['Eroare la afisarea diagramei antenei: ', ME_pattern.message]);
                warning(['Eroare la afisarea diagramei antenei: ', ME_pattern.message]);
            end
        else
            displayMessage('Receptorul ADS-B al satelitului nu a fost configurat inca. Va rugam sa configurati antena mai intai (Pasul 11).');
        end
    end




    function analyzeADSBLink()
        if ~isempty(aircraftADSBTransmitter) && ~isempty(airportADSBReceiver) && ~isempty(satelliteADSBReceiver)
            lnkADSB = link(aircraftADSBTransmitter, [airportADSBReceiver, satelliteADSBReceiver]);
            [eL,time] = ebno(lnkADSB);
            marginADSB = eL - repmat([airportADSBReceiver.RequiredEbNo,satelliteADSBReceiver.RequiredEbNo]',[1,size(eL,2)]);
            figure('Name', 'Marja Legaturii ADS-B Out', 'NumberTitle', 'off');
            plot(time,max(marginADSB),"r")
            axis tight
            grid on
            xlabel("Timp");
            ylabel("Marja (dB)");
            title("Marja legaturii ADS-B Out in functie de timp");
            assignin('base', 'lnkADSB', lnkADSB);
            displayMessage('Analiza legaturii ADS-B realizata.');
        else
            displayMessage('Transmitatorul aeronavei si receptoarele aeroporturilor/satelitilor trebuie configurate mai intai.');
        end
    end




    function playScenario()
        if ~isempty(sc) && ~isempty(aircraft) && ~isempty(viewer)
            viewerFigHandle = findobj ('Type', 'figure', 'Tag', 'SatelliteScenarioViewerFigure');
            if isempty(viewerFigHandle)
                viewerFigHandle = findobj('Type', 'figure', 'Name', 'Satellite Scenario Viewer');
            end
            if isvalid(viewerFigHandle)
                set(viewerFigHandle, 'Visible', 'on');
                figure(viewerFigHandle);
            else
                displayMessage('Avertisment: Fereastra vizualizatorului nu a putut fi gasita. Asigurati-va ca este deschisa.');
            end
            viewer.PlaybackSpeedMultiplier = 5;
            if isvalid(aircraft)
                camtarget(viewer,aircraft);
                drawnow;
            else
                displayMessage('Avertisment: Obiectul aeronavei nu este valid pentru urmarirea camerei.');
            end
            play(sc);
            displayMessage('Scenariul 3D este redat.');
        else
            displayMessage('Scenariul, aeronava si vizualizatorul trebuie create mai intai.');
        end
    end




    function openHelpDocument(src, event)
        helpFileName = 'DOCUMENTATIE_RC_PROIECT_FINAL.pdf';
        if exist(helpFileName, 'file') == 2
            winopen(helpFileName);
        else
            warndlg(['Fisierul de ajutor "', helpFileName, '" nu a fost gasit.'], 'Fisier Lipsa');
        end
    end
end