%Load Attune_MS_data
clear, clc
AMS1_N=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\028_Attune_optimised_dynamic_lax_1BW\Data\028_Attune_optimised_dynamic_lax_1BW_Neutral_flex_1of1_1_Main.tdms');
AMS1_A=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\028_Attune_optimised_dynamic_lax_1BW\Data\028_Attune_optimised_dynamic_lax_1BW_90N_ant_flex_1of1_1_Main_processed.tdms');
AMS1_P=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\028_Attune_optimised_dynamic_lax_1BW\Data\028_Attune_optimised_dynamic_lax_1BW_90N_post_flex_1of1_1_Main_processed.tdms');
AMS1_I=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\028_Attune_optimised_dynamic_lax_1BW\Data\028_Attune_optimised_dynamic_lax_1BW_5Nm_int_flex_1of1_1_Main_processed.tdms');
AMS1_E=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\028_Attune_optimised_dynamic_lax_1BW\Data\028_Attune_optimised_dynamic_lax_1BW_5Nm_ext_flex_1of1_1_Main_processed.tdms');
AMS1_Valg=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\028_Attune_optimised_dynamic_lax_1BW\Data\028_Attune_optimised_dynamic_lax_1BW_8Nm_valg_flex_1of1_1_Main_processed.tdms');

AMS=[AP_data_extraction AMS1_N,AMS1_A,AMS1_P,AMS1_I,AMS1_E,AMS1_Valg];

% AMS_Neutral=[AP_data_extraction(AMS1_N);AP_data_extraction(AMS2_N);AP_data_extraction(AMS3_N);AP_data_extraction_XLS(AMS4_N);AP_data_extraction(AMS5_N);AP_data_extraction(AMS6_N)];
% AMS_Anterior=[AP_data_extraction(AMS1_A);AP_data_extraction(AMS2_A);AP_data_extraction(AMS3_A);AP_data_extraction_XLS(AMS4_A);AP_data_extraction(AMS5_A);AP_data_extraction(AMS6_A)];
% AMS_Posterior=[AP_data_extraction(AMS1_P);AP_data_extraction(AMS2_P);AP_data_extraction(AMS3_P);AP_data_extraction_XLS(AMS4_P);AP_data_extraction(AMS5_P);AP_data_extraction(AMS6_P)];
% AMS_antlax=AMS_Anterior-AMS_Neutral;
% AMS_postlax=AMS_Posterior-AMS_Neutral;
% 
% AMS_Neutral_IR=[IR_data_extraction(AMS1_N);IR_data_extraction(AMS2_N);IR_data_extraction(AMS3_N);IR_data_extraction_XLS(AMS4_N);IR_data_extraction(AMS5_N);IR_data_extraction(AMS6_N)];
% AMS_Anterior_IR=[IR_data_extraction(AMS1_A);IR_data_extraction(AMS2_A);IR_data_extraction(AMS3_A);IR_data_extraction_XLS(AMS4_A);IR_data_extraction(AMS5_A);IR_data_extraction(AMS6_A)];
% AMS_Posterior_IR=[IR_data_extraction(AMS1_P);IR_data_extraction(AMS2_P);IR_data_extraction(AMS3_P);IR_data_extraction_XLS(AMS4_P);IR_data_extraction(AMS5_P);IR_data_extraction(AMS6_P)];
% AMS_IRlax_ant=AMS_Anterior_IR-AMS_Neutral_IR;
% AMS_IRlax_post=AMS_Posterior_IR-AMS_Neutral_IR;

PER_N=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Data\035_Persona_optimised_dynamic_lax_1BW_Neutral_flex_1of1_1_Main_processed.tdms');
PER_A=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Data\035_Persona_optimised_dynamic_lax_1BW_90N_ant_flex_1of1_1_Main_processed.tdms');
PER_P=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Data\035_Persona_optimised_dynamic_lax_1BW_90N_post_flex_1of1_1_Main_processed.tdms');
PER_I=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Data\035_Persona_optimised_dynamic_lax_1BW_5Nm_int_flex_1of1_1_Main_processed.tdms');
PER_E=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Data\035_Persona_optimised_dynamic_lax_1BW_5Nm_ext_flex_1of1_1_Main_processed.tdms');
PER_Valg=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\035_Persona_optimised_dynamic_lax_1BW\Data\035_Persona_optimised_dynamic_lax_1BW_8Nm_valg_flex_1of1_1_Main_processed.tdms');

PER=[PER_N,PER_A,PER_P,PER_I,PER_E,PER_Valg];

% PER_Neutral=[AP_data_extraction(PER1_N);AP_data_extraction(PER2_N);AP_data_extraction(PER3_N);AP_data_extraction_XLS(PER4_N);AP_data_extraction(PER5_N);AP_data_extraction_XLS(PER6_N)];
% PER_Anterior=[AP_data_extraction(PER1_A);AP_data_extraction(PER2_A);AP_data_extraction(PER3_A);AP_data_extraction_XLS(PER4_A);AP_data_extraction(PER5_A);AP_data_extraction_XLS(PER6_A)];
% PER_Posterior=[AP_data_extraction(PER1_P);AP_data_extraction(PER2_P);AP_data_extraction(PER3_P);AP_data_extraction(PER4_P);AP_data_extraction(PER5_P);AP_data_extraction(PER6_P)];
% PER_antlax=PER_Anterior-PER_Neutral;
% PER_postlax=PER_Posterior-PER_Neutral;
% 
% PER_Neutral_IR=[IR_data_extraction(PER1_N);IR_data_extraction(PER2_N);IR_data_extraction(PER3_N);IR_data_extraction_XLS(PER4_N);IR_data_extraction(PER5_N);IR_data_extraction_XLS(PER6_N)];
% PER_Anterior_IR=[IR_data_extraction(PER1_A);IR_data_extraction(PER2_A);IR_data_extraction(PER3_A);IR_data_extraction_XLS(PER4_A);IR_data_extraction(PER5_A);IR_data_extraction_XLS(PER6_A)];
% PER_Posterior_IR=[IR_data_extraction(PER1_P);IR_data_extraction(PER2_P);IR_data_extraction(PER3_P);IR_data_extraction(PER4_P);IR_data_extraction(PER5_P);IR_data_extraction(PER6_P)];
% PER_IRlax_ant=PER_Anterior_IR-PER_Neutral_IR;
% PER_IRlax_post=PER_Posterior_IR-PER_Neutral_IR;


% %Load Triathlon data

TRI_N=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\039_Triathlon_optimised_dynamic_lax_1BW\Data\039_Triathlon_optimised_dynamic_lax_1BW_Neutral_flex_1of1_1_Main_processed.tdms');
TRI_A=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\039_Triathlon_optimised_dynamic_lax_1BW\Data\039_Triathlon_optimised_dynamic_lax_1BW_90N_ant_flex_1of1_1_Main_processed.tdms');
TRI_P=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\039_Triathlon_optimised_dynamic_lax_1BW\Data\039_Triathlon_optimised_dynamic_lax_1BW_90N_post_flex_1of1_1_Main_processed.tdms');
TRI_I=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\039_Triathlon_optimised_dynamic_lax_1BW\Data\039_Triathlon_optimised_dynamic_lax_1BW_5Nm_int_flex_1of1_1_Main_processed.tdms');
TRI_E=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\039_Triathlon_optimised_dynamic_lax_1BW\Data\039_Triathlon_optimised_dynamic_lax_1BW_5Nm_ext_flex_1of1_1_Main_processed.tdms');
TRI_Valg=tdmsread('C:\Users\sholthof\Desktop\Imperial\PHD\Matlab\CS calculations\SH25\039_Triathlon_optimised_dynamic_lax_1BW\Data\039_Triathlon_optimised_dynamic_lax_1BW_8Nm_valg_flex_1of1_1_Main_processed.tdms');

TRI=[TRI_N,TRI_A,TRI_P,TRI_I,TRI_E,TRI_Valg];

% TRI_Neutral=[AP_data_extraction(TRI1_N);AP_data_extraction(TRI2_N);AP_data_extraction(TRI3_N);AP_data_extraction_XLS(TRI4_N);AP_data_extraction(TRI5_N);AP_data_extraction_XLS(TRI6_N)];
% TRI_Anterior=[AP_data_extraction(TRI1_A);AP_data_extraction(TRI2_A);AP_data_extraction(TRI3_A);AP_data_extraction_XLS(TRI4_A);AP_data_extraction(TRI5_A);AP_data_extraction_XLS(TRI6_A)];
% TRI_Posterior=[AP_data_extraction(TRI1_P);AP_data_extraction(TRI2_P);AP_data_extraction(TRI3_P);AP_data_extraction(TRI4_P);AP_data_extraction(TRI5_P);AP_data_extraction(TRI6_P)];
% TRI_antlax=TRI_Anterior-TRI_Neutral;
% TRI_postlax=TRI_Posterior-TRI_Neutral;
% 
% TRI_Neutral_IR=[IR_data_extraction(TRI1_N);IR_data_extraction(TRI2_N);IR_data_extraction(TRI3_N);IR_data_extraction_XLS(TRI4_N);IR_data_extraction(TRI5_N);IR_data_extraction_XLS(TRI6_N)];
% TRI_Anterior_IR=[IR_data_extraction(TRI1_A);IR_data_extraction(TRI2_A);IR_data_extraction(TRI3_A);IR_data_extraction_XLS(TRI4_A);IR_data_extraction(TRI5_A);IR_data_extraction_XLS(TRI6_A)];
% TRI_Posterior_IR=[IR_data_extraction(TRI1_P);IR_data_extraction(TRI2_P);IR_data_extraction(TRI3_P);IR_data_extraction(TRI4_P);IR_data_extraction(TRI5_P);IR_data_extraction(TRI6_P)];
% TRI_IRlax_ant=TRI_Anterior_IR-TRI_Neutral_IR;
% TRI_IRlax_post=TRI_Posterior_IR-TRI_Neutral_IR;

%%Combine

Neutral=[AMS_Neutral;PER_Neutral;TRI_Neutral];
antlax=[AMS_antlax;PER_antlax;TRI_antlax];
antpos=[AMS_Anterior;PER_Anterior;TRI_Anterior];
postlax=[AMS_postlax;PER_postlax;TRI_postlax];
postpos=[AMS_Posterior;PER_Posterior;TRI_Posterior];
IR_ant=[AMS_IRlax_ant;PER_IRlax_ant;TRI_IRlax_ant];
IR_post=[AMS_IRlax_post;PER_IRlax_post;TRI_IRlax_post];
IRpos_ant=[AMS_Anterior_IR;PER_Anterior_IR;TRI_Anterior_IR];
IRpos_post=[AMS_Posterior_IR;PER_Posterior_IR;TRI_Posterior_IR];
