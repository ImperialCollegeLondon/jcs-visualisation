function [JCS_flex, JCS_ext, JCS_flex_digitised, JCS_ext_digitised] = tdms_data_extraction_optvsdig(data_in)
       
 JCS_flex = [];
    JCS_ext = [];
    JCS_flex_digitised = [];
    JCS_ext_digitised = [];
    flex_ind = [];
    ext_ind = [];

for c = 1:numel(data_in)
        
        data = data_in{c};

        if ismember('JCS_Posterior', data.Properties.VariableNames)
            ap = data.JCS_Posterior;
            flex = data.JCS_Flexion;
            peakFlex = find(flex == max(flex));
            disp(peakFlex)
            ir = data.('JCS_Internal Rotation');
            vv = data.('JCS_Valgus');
            ml=data.("JCS_Medial");
            si=data.("JCS_Superior");
            flex_flex = flex(1:peakFlex);
            flex_ext = flex(peakFlex:end);

            flex_ind = find_indices(flex_flex, 0:round(max(flex)));
            ext_ind = find_indices(flex_ext, 0:round(max(flex)));
            ap_flex = ap(flex_ind)';
            ap_ext = ap(ext_ind)';
            ir_flex = ir(flex_ind)';
            ir_ext = ir(ext_ind)';
            vv_flex = vv(flex_ind)';
            vv_ext = vv(ext_ind)';
            ml_flex = ml(flex_ind)';
            ml_ext = ml(ext_ind)';
            si_flex = si(flex_ind)';
            si_ext = si(ext_ind)';
    
            JCS_flex = [(0:round(max(flex))); ap_flex; ir_flex; vv_flex;ml_flex;si_flex]';
            JCS_ext= [(0:round(max(flex))); ap_ext; ir_ext; vv_ext;ml_ext;si_ext]';
        end

      if ~isempty(flex_ind) &&  ismember('JCS_digitised_Posterior', data.Properties.VariableNames)
        ap_digitised = data.JCS_digitised_Posterior;
%         flex_digitised = data.JCS_digitised_Flexion;
%         peakFlex = find(flex_digitised == max(flex_digitised));
        ir_digitised = data.('JCS_digitised_Internal Rotation');
        vv_digitised = data.('JCS_digitised_Valgus');
        ml_digitised=data.("JCS_digitised_Medial");
        si_digitised=data.("JCS_digitised_Superior");
%         flex_flex_digitised = flex_digitised(1:peakFlex);
%         flex_ext_digitised = flex_digitised(peakFlex:end);
% 
%         flex_ind_digitised = find_indices(flex_flex_digitised, 0:round(max(flex_digitised)));
%         ext_ind_digitised = find_indices(flex_ext_digitised, 0:round(max(flex_digitised)));
        ap_flex_digitised = ap_digitised(flex_ind)';
        ap_ext_digitised = ap_digitised(ext_ind)';
        ir_flex_digitised = ir_digitised(flex_ind)';
        ir_ext_digitised = ir_digitised(ext_ind)';
        vv_flex_digitised = vv_digitised(flex_ind)';
        vv_ext_digitised = vv_digitised(ext_ind)';
        ml_flex_digitised = ml_digitised(flex_ind)';
        ml_ext_digitised = ml_digitised(ext_ind)';
        si_flex_digitised = si_digitised(flex_ind)';
        si_ext_digitised = si_digitised(ext_ind)';

         JCS_flex_digitised= [(0:round(max(flex))); ap_flex_digitised; ir_flex_digitised; vv_flex_digitised;ml_flex_digitised;si_flex_digitised]';
         JCS_ext_digitised= [(0:round(max(flex))); ap_ext_digitised; ir_ext_digitised; vv_ext_digitised;ml_ext_digitised;si_ext_digitised]';
      end
      end
end

function indices = find_indices(signal, values)
    indices = arrayfun(@(val) min(find(abs(signal - val) == min(abs(signal - val)))), values);
end