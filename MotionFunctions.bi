'--------------------------------------------
'Author      : Dr. Fritz Faulhaber GmbH & Co. KG
'Date        : 12.09.2018
'--------------------------------------------
'Description:
'  Motion library functions:
'    - Enable()
'    - Disable()
'    - QuickStop()
'    - MoveAbs(TargetPos,Immediate)
'    - MoveRel(TargetPos,Immediate)
'    - WaitPos()
'  To be used in sequence programs for 
'  Motion Controllers of the family MC V3.x.
'-------------------------------------------- 
#INCLUDE "MotionParameters.bi"                         
                                         
#DEFINE CiAStatusMask $6F
                   
'--------------------------------------------
' Enable()
' will start the CiA 402 state machine or re-enable
' the control
' returns only after the OperationEnabled state is reached
'--------------------------------------------

FUNCTION Enable ()    

DIM EnState 
DIM CiAStatus     

'reset the local step counter
EnState = 0
'initial check the status word
CiAStatus = GETOBJ Statusword & CiAStatusMask
 
'check for being in stopped mode
IF(CiAStatus = CiAStatus_QuickStop) THEN
   'enable directly   
   SETOBJ Controlword = CiACmdEnableOperation
   EnState = 1
ELSEIF(CiAStatus = CiAStatus_OperationEnabled) THEN
   'drive is already enabled               
   EnState = 2 
'otherwise it's safe to disable first
ELSEIF(CiAStatus <> CiAStatus_SwitchOnDisabled)THEN
   'we need to send a shutdown first
   SETOBJ Controlword = CiACmdDisableVoltage
END IF
              
DO 
   'cyclically check the status word
   CiAStatus = GETOBJ Statusword & CiAStatusMask
   IF(EnState = 0) THEN
      IF(CiAStatus = CiAStatus_SwitchOnDisabled)THEN
         'send the enable signature
         SETOBJ Controlword = CiACmdShutdown
         SETOBJ Controlword = CiACmdEnableOperation  
         'now wait for being enabled
         EnState = 1
      END IF
   ELSEIF (EnState = 1) THEN
      'wait for enabled
      IF (CiAStatus = CiAStatus_OperationEnabled) THEN
         EnState = 2
      END IF
   END IF
                         
LOOP UNTIL EnState = 2

END FUNCTION      

'--------------------------------------------
' Disable()
' Will stop the drive and shut the 
' CiA 402 state machine down TO the initial state
' returns only after the initial state (Switch On Disabled)
' is reached
'---------------------------------------------

FUNCTION Disable()

DIM DiState 
DIM CiAStatus     

'reset the local step counter
DiState = 0
'initial check the status word
CiAStatus = GETOBJ Statusword & CiAStatusMask
 
'check for being in stopped mode
IF(CiAStatus = CiAStatus_OperationEnabled) THEN
   'send a shutdown command first to stop the motor   
   SETOBJ Controlword = CiACmdDisable
   DiState = 1
ELSE    
   'otherwise the disable voltage is the next command
   'out of quick-stop or switched on.
   DiState = 2                     
END IF

DO 
   'cyclically check the status word
   CiAStatus = GETOBJ Statusword & CiAStatusMask
   IF(DiState = 1) THEN
      IF(CiAStatus = CiAStatus_SwitchedOn)THEN
         'only now it's safe to send the disable voltage command
         DiState = 2
      END IF
   ELSEIF (DiState = 2) THEN
      'wait for enabled
      SETOBJ Controlword = CiACmdDisableVoltage
          DiState = 3
   ELSEIF (DiState = 3) THEN
      'wait for final state
      IF (CiAStatus = CiAStatus_SwitchOnDisabled) THEN
         DiState = 4
      END IF
   END IF
LOOP UNTIL DiState = 4

END FUNCTION

'--------------------------------------------
' QuickStop()
' Stop the motion but stay enabled @ speed = 0
' Returns after either the QuickStop State or the
' Switch On Disabled state is reached
' Switch On Disabled will be reached (no control active)
' depending on the QuickStopOptionCode 0x605A.00
'--------------------------------------------

FUNCTION QuickStop()

DIM CiAStatus
DIM QsState

'initial check the status word
CiAStatus = GETOBJ Statusword & CiAStatusMask
QsState = 0

'check FOR OperationEnabled state
IF CiAStatus = CiAStatus_OperationEnabled THEN
   SETOBJ Controlword = CiACmdQuickStop
   QsState = 1
ELSE
   QsState = 2
END IF

DO 
   'cyclically check the status word
   CiAStatus = GETOBJ Statusword & CiAStatusMask 
   IF CiAStatus = CiAStatus_QuickStop THEN
      QsState = 2
   ELSEIF CiAStatus = CiAStatus_SwitchOnDisabled THEN
      QsState = 2
   END IF
LOOP UNTIL QsState = 2

END FUNCTION 

'--------------------------------------------
' MoveAbs(TargetPos,Immediate)
' MoveAbs will write the TargetPos and will start 
' the movement. As a rising edge in bit 4 is necessary
' a bit4 = 0 command will be sent first
' returns immediately
'--------------------------------------------

FUNCTION MoveAbs(TargetPos,Immediate)
DIM tempCtrlWord

tempCtrlWord = CiACmdEnableOperation 
SETOBJ Controlword = tempCtrlWord
SETOBJ TargetPosition = TargetPos

tempCtrlWord = tempCtrlWord | CiACmdStartBit
IF Immediate THEN
   tempCtrlWord = tempCtrlWord | CiACmdImmediateBit
ENDIF
SETOBJ Controlword = tempCtrlWord
SETOBJ Controlword = CiACmdEnableOperation

DO
LOOP UNTIL ((GETOBJ Statusword & CiAStatus_InPosBit) = 0)

END FUNCTION
                             
'--------------------------------------------
' MoveRel(TargetPos,Immediate)
' MoveRel will write the TargetPos and will start 
' the movement. As a rising edge in bit 4 is necessary
' a bit4 = 0 command will be sent first
' returns immediately
'--------------------------------------------

FUNCTION MoveRel(TargetPos,Immediate)
DIM tempCtrlWord

tempCtrlWord = CiACmdEnableOperation 
SETOBJ Controlword = tempCtrlWord
SETOBJ TargetPosition = TargetPos

tempCtrlWord = tempCtrlWord | CiACmdStartBit | CiACmdRelPosBit
IF Immediate THEN
   tempCtrlWord = tempCtrlWord | CiACmdImmediateBit
ENDIF
SETOBJ Controlword = tempCtrlWord
SETOBJ Controlword = CiACmdEnableOperation

DO
LOOP UNTIL ((GETOBJ Statusword & CiAStatus_InPosBit) = 0)

END FUNCTION

'--------------------------------------------
' WaitPos()
' can be called directly after either the
' MoveRel or the MoveAbs FUNCTION call
' will wait FOR the InPos Bit being set
' will NOT check FOR a rising edge!

FUNCTION WaitPos()
DO
LOOP UNTIL (GETOBJ Statusword & CiAStatus_InPosBit)

END FUNCTION




