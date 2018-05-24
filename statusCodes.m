function status = statusCodes(num)
    switch num
        case 0                       % function completed OK
            status = "STAT_OK";
        case 1                    % generic error return (EPERM)
            status = "STAT_ERROR";
        case 2                   % function would block here (call again)
            status = "STAT_EAGAIN";
        case 3                     % function had no-operation
            status = "STAT_NOOP";
        case 4                 % operation is complete
            status = "STAT_COMPLETE";
        case  5                 % operation was shutdown (terminated gracefully)
            status = "STAT_SHUTDOWN";
        case 6                    % system panic (not graceful)
            status = "STAT_PANIC";
        case 7                      % function returned end-of-line
            status = "STAT_EOL";
        case 8                      % function returned end-of-file
            status = "STAT_EOF";
        case 9
            status = "STAT_FILE_NOT_OPEN";
        case 10
            status = "STAT_FILE_SIZE_EXCEEDED";
        case 11
            status = "STAT_NO_SUCH_DEVICE";
        case 12
            status = "STAT_BUFFER_EMPTY";
        case 13
            status = "STAT_BUFFER_FULL";
        case 14
            status = "STAT_BUFFER_FULL_FATAL";
        case 15            % initializing - not ready for use
            status = "STAT_INITIALIZING";
        case 16    % this code actually emitted from boot loader, not g2
            status = "STAT_ENTERING_BOOT_LOADER";
        case 17
            status = "STAT_FUNCTION_IS_STUBBED";
        case 18                   % system alarm triggered
            status = "STAT_ALARM";
        case 19              % suppress results display - presumably handled upstream
            status = "STAT_NO_DISPLAY";

        % Internal errors and startup messages
        case 20          % unrecoverable internal error
            status = "STAT_INTERNAL_ERROR";
        case 21    % number range other than by user input
            status = "STAT_INTERNAL_RANGE_ERROR";
        case 22    % number conversion error
            status = "STAT_FLOATING_POINT_ERROR";
        case 23
            status = "STAT_DIVIDE_BY_ZERO";
        case 24
            status = "STAT_INVALID_ADDRESS";
        case 25
            status = "STAT_READ_ONLY_ADDRESS";
        case 26
            status = "STAT_INIT_FAILURE";
        case 27                % was ALARMED in 0.97
            status = "STAT_ERROR_27";
        case 28
            status = "STAT_FAILED_TO_GET_PLANNER_BUFFER";
        case 29 % used for test
            status = "STAT_GENERIC_EXCEPTION_REPORT";

        case 30
            status = "STAT_PREP_LINE_MOVE_TIME_IS_INFINITE";
        case 31
            status = "STAT_PREP_LINE_MOVE_TIME_IS_NAN";
        case 32
            status = "STAT_FLOAT_IS_INFINITE";
        case 33
            status = "STAT_FLOAT_IS_NAN";
        case 34
            status = "STAT_PERSISTENCE_ERROR";
        case 35
            status = "STAT_BAD_STATUS_REPORT_SETTING";
        case 36
            status = "STAT_FAILED_GET_PLANNER_BUFFER";

        % Assertion failures - build down from 99 until they meet the system internal errors
        case 88
            status = "STAT_BUFFER_FREE_ASSERTION_FAILURE";
        case 89
            status = "STAT_STATE_MANAGEMENT_ASSERTION_FAILURE";
        case 90
            status = "STAT_CONFIG_ASSERTION_FAILURE";
        case 91
            status = "STAT_XIO_ASSERTION_FAILURE";
        case 92
            status = "STAT_ENCODER_ASSERTION_FAILURE";
        case 93
            status = "STAT_STEPPER_ASSERTION_FAILURE";
        case 94
            status = "STAT_PLANNER_ASSERTION_FAILURE";
        case 95
            status = "STAT_CANONICAL_MACHINE_ASSERTION_FAILURE";
        case 96
            status = "STAT_CONTROLLER_ASSERTION_FAILURE";
        case 97
            status = "STAT_STACK_OVERFLOW";
        case 98                    % generic memory corruption detected by magic numbers
            status = "STAT_MEMORY_FAULT";
        case 99       % generic assertion failure - unclassified
            status = "STAT_GENERIC_ASSERTION_FAILURE";

        % Application and data input errors

        % Generic data input errors
        case 100              % parser didn't recognize the name
            status = "STAT_UNRECOGNIZED_NAME";
        case 101   % malformed line to parser
            status = "STAT_INVALID_OR_MALFORMED_COMMAND";
        case 102              % number format error
            status = "STAT_BAD_NUMBER_FORMAT";
        case 103               % an otherwise valid JSON type is not supported
            status = "STAT_UNSUPPORTED_TYPE";
        case 104         % input error: parameter cannot be set
            status = "STAT_PARAMETER_IS_READ_ONLY";
        case 105       % input error: parameter cannot be returned
            status = "STAT_PARAMETER_CANNOT_BE_READ";
        case 106           % input error: command cannot be accepted at this time
            status = "STAT_COMMAND_NOT_ACCEPTED";
        case 107       % input error: input string is too long
            status = "STAT_INPUT_EXCEEDS_MAX_LENGTH";
        case 108      % input error: value is under minimum
            status = "STAT_INPUT_LESS_THAN_MIN_VALUE";
        case 109        % input error: value is over maximum
            status = "STAT_INPUT_EXCEEDS_MAX_VALUE";
        case 110        % input error: value is out-of-range
            status = "STAT_INPUT_VALUE_RANGE_ERROR";

        case 111              % JSON input string is not well formed
            status = "STAT_JSON_SYNTAX_ERROR";
        case 112            % JSON input string has too many JSON pairs
            status = "STAT_JSON_TOO_MANY_PAIRS";
        case 113           % JSON output exceeds buffer size
            status = "STAT_JSON_OUTPUT_TOO_LONG";
        case 114           % JSON 'txt' fields cannot be nested
            status = "STAT_NESTED_TXT_CONTAINER";
        case 115             % JSON exceeded maximum nesting depth
            status = "STAT_MAX_DEPTH_EXCEEDED";
        case 116               % JSON value does not agree with variable type
            status = "STAT_MAX_DEPTH_EXCEEDED";

        % Gcode errors and warnings (Most originate from NIST - by concept, not number)
        case 130      % generic error for gcode input
            status = "STAT_GCODE_GENERIC_INPUT_ERROR";
        case 131      % G command is not supported
            status = "STAT_GCODE_COMMAND_UNSUPPORTED";
        case 132      % M command is not supported
            status = "STAT_MCODE_COMMAND_UNSUPPORTED";
        case 133    % gcode modal group error
            status = "STAT_GCODE_MODAL_GROUP_VIOLATION";
        case 134          % command requires at least one axis present
            status = "STAT_GCODE_AXIS_IS_MISSING";
        case 135   % error if G80 has axis words
            status = "STAT_GCODE_AXIS_CANNOT_BE_PRESENT";
        case 136          % an axis is specified that is illegal for the command
            status = "STAT_GCODE_AXIS_IS_INVALID";
        case 137   % WARNING: attempt to program an axis that is disabled
            status = "STAT_GCODE_AXIS_IS_NOT_CONFIGURED";
        case 138   % axis word is missing its value
            status = "STAT_GCODE_AXIS_NUMBER_IS_MISSING";
        case 139   % axis word value is illegal
            status = "STAT_GCODE_AXIS_NUMBER_IS_INVALID";

        case 140  % active plane is not programmed
            status = "STAT_GCODE_ACTIVE_PLANE_IS_MISSING";
        case 141  % active plane selected is not valid for this command
            status = "STAT_GCODE_ACTIVE_PLANE_IS_INVALID";
        case 142   % move has no feedrate
            status = "STAT_GCODE_FEEDRATE_NOT_SPECIFIED";
        case 143  % G38.2 and some canned cycles cannot accept inverse time mode
            status = "STAT_GCODE_INVERSE_TIME_MODE_CANNOT_BE_USED";
        case 144   % G38.2 and some other commands cannot have rotary axes
            status = "STAT_GCODE_ROTARY_AXIS_CANNOT_BE_USED";
        case 145         % G0 or G1 must be active for G53
            status = "STAT_GCODE_G53_WITHOUT_G0_OR_G1";
        case 146
            status = "STAT_REQUESTED_VELOCITY_EXCEEDS_LIMITS";
        case 147
            status = "STAT_CUTTER_COMPENSATION_CANNOT_BE_ENABLED";
        case 148
            status = "STAT_PROGRAMMED_POINT_SAME_AS_CURRENT_POINT";
        case 149
            status = "STAT_SPINDLE_SPEED_BELOW_MINIMUM";

        case 150
            status = "STAT_SPINDLE_SPEED_MAX_EXCEEDED";
        case 151
            status = "STAT_SPINDLE_MUST_BE_OFF";
        case 152            % some canned cycles require spindle to be turning when called
            status = "STAT_SPINDLE_MUST_BE_TURNING";
        case 153                 % RESERVED
            status = "STAT_ARC_ERROR_RESERVED";
        case 154    % trap (.05 inch/.5 mm) OR ((.0005 inch/.005mm) AND .1% of radius condition
            status = "STAT_ARC_HAS_IMPOSSIBLE_CENTER_POINT";
        case 155            % generic arc specification error
            status = "STAT_ARC_SPECIFICATION_ERROR";
        case 156  % arc is missing axis (axes) required by selected plane
            status = "STAT_ARC_AXIS_MISSING_FOR_SELECTED_PLANE";
        case 157 % one or both offsets are not specified
            status = "STAT_ARC_OFFSETS_MISSING_FOR_SELECTED_PLANE";
        case 158        % WARNING - radius arc is too large - accuracy in question
            status = "STAT_ARC_RADIUS_OUT_OF_TOLERANCE";
        case 159
            status = "STAT_ARC_ENDPOINT_IS_STARTING_POINT";

        case 160                  % P must be present for dwells and other functions
            status = "STAT_P_WORD_IS_MISSING";
        case 161                  % generic P value error
            status = "STAT_P_WORD_IS_INVALID";
        case 162
            status = "STAT_P_WORD_IS_ZERO";
        case 163                 % dwells require positive P values
            status = "STAT_P_WORD_IS_NEGATIVE";
        case 164           % G10s and other commands require integer P numbers
            status = "STAT_P_WORD_IS_NOT_AN_INTEGER";
        case 165
            status = "STAT_P_WORD_IS_NOT_VALID_TOOL_NUMBER";
        case 166
            status = "STAT_D_WORD_IS_MISSING";
        case 167
            status = "STAT_D_WORD_IS_INVALID";
        case 168
            status = "STAT_E_WORD_IS_MISSING";
        case 169
            status = "STAT_E_WORD_IS_INVALID";

        case 170
            status = "STAT_H_WORD_IS_MISSING";
        case 171
            status = "STAT_H_WORD_IS_INVALID";
        case 172
            status = "STAT_L_WORD_IS_MISSING";
        case 173
            status = "STAT_L_WORD_IS_INVALID";
        case 174
            status = "STAT_Q_WORD_IS_MISSING";
        case 175
            status = "STAT_Q_WORD_IS_INVALID";
        case 176
            status = "STAT_R_WORD_IS_MISSING";
        case 177
            status = "STAT_R_WORD_IS_INVALID";
        case 178
            status = "STAT_S_WORD_IS_MISSING";
        case 179
            status = "STAT_S_WORD_IS_INVALID";

        case 180
            status = "STAT_T_WORD_IS_MISSING";
        case 181
            status = "STAT_T_WORD_IS_INVALID";

        % g2core errors and warnings
        case 200
            status = "STAT_GENERIC_ERROR";
        case 201            % move is less than minimum length
            status = "STAT_MINIMUM_LENGTH_MOVE";
        case 202              % move is less than minimum time
            status = "STAT_MINIMUM_TIME_MOVE";
        case 203               % a limit switch was hit causing shutdown
            status = "STAT_LIMIT_SWITCH_HIT";
        case 204      % command was not processed because machine is alarmed
            status = "STAT_COMMAND_REJECTED_BY_ALARM";
        case 205   % command was not processed because machine is shutdown
            status = "STAT_COMMAND_REJECTED_BY_SHUTDOWN";
        case 206      % command was not processed because machine is paniced
            status = "STAT_COMMAND_REJECTED_BY_PANIC";
        case 207                       % ^d received (job kill)
            status = "STAT_KILL_JOB";
        case 208                        % no GPIO exists for this value
            status = "STAT_NO_GPIO";

        case 209      % temperature controls err'd out
            status = "STAT_TEMPERATURE_CONTROL_ERROR";

        case 220            % soft limit error - axis unspecified
            status = "STAT_SOFT_LIMIT_EXCEEDED";
        case 221       % soft limit error - X minimum
            status = "STAT_SOFT_LIMIT_EXCEEDED_XMIN";
        case 222       % soft limit error - X maximum
            status = "STAT_SOFT_LIMIT_EXCEEDED_XMAX";
        case 223       % soft limit error - Y minimum
            status = "STAT_SOFT_LIMIT_EXCEEDED_YMIN";
        case 224       % soft limit error - Y maximum
            status = "STAT_SOFT_LIMIT_EXCEEDED_YMAX";
        case 225       % soft limit error - Z minimum
            status = "STAT_SOFT_LIMIT_EXCEEDED_ZMIN";
        case 226       % soft limit error - Z maximum
            status = "STAT_SOFT_LIMIT_EXCEEDED_ZMAX";
        case 227       % soft limit error - A minimum
            status = "STAT_SOFT_LIMIT_EXCEEDED_AMIN";
        case 228       % soft limit error - A maximum
            status = "STAT_SOFT_LIMIT_EXCEEDED_AMAX";
        case 229       % soft limit error - B minimum
            status = "STAT_SOFT_LIMIT_EXCEEDED_BMIN";

        case 230       % soft limit error - B maximum
            status = "STAT_SOFT_LIMIT_EXCEEDED_BMAX";
        case 231       % soft limit error - C minimum
            status = "STAT_SOFT_LIMIT_EXCEEDED_CMIN";
        case 232       % soft limit error - C maximum
            status = "STAT_SOFT_LIMIT_EXCEEDED_CMAX";
        case 233        % soft limit err on arc
            status = "STAT_SOFT_LIMIT_EXCEEDED_ARC";

        case 240            % homing cycle did not complete
            status = "STAT_HOMING_CYCLE_FAILED";
        case 241
            status = "STAT_HOMING_ERROR_BAD_OR_NO_AXIS";
        case 242
            status = "STAT_HOMING_ERROR_ZERO_SEARCH_VELOCITY";
        case 243
            status = "STAT_HOMING_ERROR_ZERO_LATCH_VELOCITY";
        case 244
            status = "STAT_HOMING_ERROR_TRAVEL_MIN_MAX_IDENTICAL";
        case 245
            status = "STAT_HOMING_ERROR_NEGATIVE_LATCH_BACKOFF";
        case 246
            status = "STAT_HOMING_ERROR_HOMING_INPUT_MISCONFIGURED";
        case 247
            status = "STAT_HOMING_ERROR_MUST_CLEAR_SWITCHES_BEFORE_HOMING";
        case 248
            status = "STAT_ERROR_248";
        case 249
            status = "STAT_ERROR_249";

        case 250             % probing cycle did not complete
            status = "STAT_PROBE_CYCLE_FAILED";
        case 251
            status = "STAT_PROBE_TRAVEL_TOO_SMALL";
        case 252
            status = "STAT_NO_PROBE_SWITCH_CONFIGURED";
        case 253
            status = "STAT_MULTIPLE_PROBE_SWITCHES_CONFIGURED";
        case 254
            status = "STAT_PROBE_SWITCH_ON_ABC_AXIS";

        case 255
            status = "STAT_ERROR_255";
    end
end