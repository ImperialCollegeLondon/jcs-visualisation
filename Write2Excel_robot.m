function [DataTable] = Write2Excel_robot(kinematics,file2writeto,implant_type)

passive=false;

if strcmp(implant_type, 'intact')
    Columncounter = 'H';
    lvdtcounter= 'N';
elseif strcmp(implant_type, 'attune')
    Columncounter = 'O';
    lvdtcounter= 'U';
elseif strcmp(implant_type, 'persona')
    Columncounter = 'AB';
    lvdtcounter= 'N';
elseif strcmp(implant_type, 'triathlon')
    Columncounter = 'AC';
    lvdtcounter= 'AI';
elseif strcmp(implant_type, 'neutral')
    Columncounter = 'A';
    lvdtcounter= 'G';
    passive=true; % Writes neutral path into each sheet
  
end

filename = file2writeto;

if passive
    for i=1:8   
    writetable(kinematics{1}(:,:),filename,'Sheet',i,'Range',strcat(Columncounter,'2'));
    disp(i)
    disp(Columncounter)
    end
end

if passive==false
for i=length(kinematics):-1:1    
    writetable(kinematics{i}(:,:),filename,'Sheet',i,'Range',strcat(Columncounter,'2'));
    disp(i)
    disp(Columncounter)
end
end



