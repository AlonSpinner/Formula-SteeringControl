'Author: Eyal Baruch & Alon Spinner & Amir Saad & Idan Roth & Ohad Mochly
'Date: 26/5/19   
'--------------------------------------------
'Description:

'given input:      
'PWM signal produced from arduino connected TO digital input 1
'arduino ground connected TO analog ground
                                                
'produces output:
'moves motor into position corresponding linearly TO PWM signal Duty Cycle
'motor position = Const * Duty Cycle  (Duty Cycle ranges [0,32767]) AND corresponds TO [0,255] PWM in input    
                                                               
'Important:
'All information required is found in "Drive Functions" PDF.
'Search FOR 'Analong                  
'The PWM signal              
'--------------------------------------------
#INCLUDE "MotionParameters.bi"                              
#INCLUDE "MotionMacros.bi"                    
#INCLUDE "MotionFunctions.bi"
                                                                                                          
MC.SetOpmodeHoming '$6060.00=-2 'define APC Homing 
SETOBJ $6098.00=37 'set homing mode method. refernece value is zero.      
Enable()    
                                                
MC.SetOpmodeAPC  'SETOBJ $6060.00=-2 'define APC mode    
SETOBJ $2331.04=07 'define pwm input through digital                                      
SETOBJ $2317.01=1 'PWM Digital input - pin 1                                  
SETOBJ $2317.04=$E8B601E0 'Duty Cycle Gain\ Position Factor (2 bytes FOR numinator AND 2 bytes FOR dominator) 
SETOBJ $2317.05=49151 'incremental offset - 24*100*/360*4096 (we want TO start from -24 degrees) - maybe needs TO be changed           
SETOBJ $6080.00=400 'maximal velocity - needs TO be changed     
