function figHand = PlotModelFitInteractive(model, params, data)
  figHand = figure;
  
  paramsCur = params;
  PlotModelFit(model, paramsCur, data);
  pos = get(gca, 'Position');
  
  Nparams = length(model.paramNames);
  vertSpacing = (.35/Nparams);
  if vertSpacing>0.10
    vertSpacing = 0.10;
  end
  maxPos = min([.35 vertSpacing*Nparams]);
  pos(2) = maxPos + 0.12;
  pos(4) = 1 - maxPos - 0.15;
  set(gca, 'Position', pos);
  height = vertSpacing-0.03;
  for i=1:Nparams
    if ~isinf(model.upperbound(i))
      MappingFunction{i} = @(percent) (model.lowerbound(i) ...
        + (model.upperbound(i)-model.lowerbound(i))*percent);
      InverseMappingFunction{i} = @(val) ((val-model.lowerbound(i)) ...
        / (model.upperbound(i)-model.lowerbound(i)));
    else
      if isinf(model.lowerbound(i))
        % Should probably use a logistic with variable mean. For now just
        % error!
        error('Can''t have lower and upperbound of a parameter be Inf');
      else
        MappingFunction{i} = @(percent) (-log(1-percent)*params(i)*2);
        InverseMappingFunction{i} = @(val) (1-exp(-val/(params(i)*2)));
      end
    end
    
    invertedMapping = InverseMappingFunction{i}(params(i));    
    slider(i) = uicontrol(...
      'Parent',gcf,...
      'Units','normalized',...
      'Callback', @(hObject,eventdata) slider_Callback(hObject, i),...
      'Position',[0.10 maxPos-(i-1)*vertSpacing-height 0.75 height],...
      'Style','slider', ...
      'UserData', MappingFunction{i}, ...
      'Value', invertedMapping);
    
    uicontrol(...
      'Parent',gcf,...
      'Units','normalized',...
      'BackgroundColor',[1 1 1],...
      'Style','text',...
      'FontSize', 12, ...
      'FontWeight', 'bold', ...
      'Position',[0.02 maxPos-(i-1)*vertSpacing-height 0.08 height],...
      'String', model.paramNames{i});
    
    curVals(i) = uicontrol(...
      'Parent',gcf,...
      'Units','normalized',...
      'BackgroundColor',[1 1 1],...
      'Style','edit',...
      'FontSize', 12, ...
      'FontWeight', 'bold', ...
      'Position',[0.85 maxPos-(i-1)*vertSpacing-height 0.13 height],...
      'String', sprintf('%0.2f', paramsCur(i)), ...
      'Callback', @(hObject,eventdata) edit_Callback(hObject, i), ...
      'UserData', InverseMappingFunction{i});
  end
  
  function edit_Callback(hObject, which)
    curValue = str2double(get(hObject,'String'));
    if isnan(curValue)
      set(hObject, 'String', sprintf('%0.2f', paramsCur(which)));
      beep; warning('Not a number!');
      return;
    end
    paramsCur(which) = curValue;
    
    inverseMappingFunc = get(hObject, 'UserData');
    set(slider(which), 'Value', inverseMappingFunc(curValue));
    slider_Callback(slider(which), which);
  end
  
  function slider_Callback(hObject, which)
    curValue = get(hObject,'Value');
    mappingFunc = get(hObject, 'UserData');
    paramsCur(which) = mappingFunc(curValue);
    hold off;
    PlotModelFit(model, paramsCur, data);
    set(curVals(which), 'String', sprintf('%0.2f', paramsCur(which)));
  end
end




