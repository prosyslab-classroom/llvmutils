(** {2 Debug information} *)

type debug_loc = {
  filename : string;
  funname : string;
  line : int;
  column : int;
}

val debug_location : Llvm.llcontext -> Llvm.llvalue -> debug_loc option

(** {2 Helper functions} *)

val iter_all_instr : (Llvm.llvalue -> unit) -> Llvm.llmodule -> unit
(** [iter_all_instr f m] applies function [f] in turn to all instructions in [m]. *)

val fold_left_all_instr :
  ('a -> Llvm.llvalue -> 'a) -> 'a -> Llvm.llmodule -> 'a
(** [fold_left_all_instr f a m] returns [f (... f (f (f a i1) i2) i3 ...) in], where [i1..in] are the instructions in [m]. *)

val find_main : Llvm.llmodule -> Llvm.llvalue
(** [find_main llm] returns a function with name [main] in a given llmodule [llm]. If no such function exists, [failwith "main funtion not found"]. *)

val entry_point : Llvm.llvalue -> (Llvm.llbasicblock, Llvm.llvalue) Llvm.llpos
(** [entry_point fn] returns the first position of the instruction list corresponding to the function [fn]. *)

val get_function : Llvm.llvalue -> Llvm.llvalue
(** [get_function instr] returns the function that contains [instr]. *)

val get_next_nonphi :
  Llvm.llvalue -> (Llvm.llbasicblock, Llvm.llvalue) Llvm.llpos
(** [get_next_nonphi instr] returns the position of the instruction that is not [Llvm.Opcode.PHI] after [instr]. *)

val get_next_phi : Llvm.llvalue -> (Llvm.llbasicblock, Llvm.llvalue) Llvm.llpos
(** [get_next_phi instr] returns the position of the instruction that is [Llvm.Opcode.PHI] after [instr]. *)

val neg_pred : Llvm.Icmp.t -> Llvm.Icmp.t
(** [neg_pred pr] is negated form of the predicate [pr]. *)

val flip_pred : Llvm.Icmp.t -> Llvm.Icmp.t
(** [flip_pred pr] is flipped form of the predicate [pr]. *)

(** {2 Test functions} *)

val is_assignment : Llvm.Opcode.t -> bool
(** check if a given LLVM instruction is an assignment. *)

val is_phi : Llvm.llvalue -> bool
(** check if a given LLVM instruction is a phi node. *)

val is_unary_op : Llvm.Opcode.t -> bool
(** check if a given LLVM instruction is a unary operator. *)

val is_binary_op : Llvm.Opcode.t -> bool
(** check if a given LLVM instruction is a binary operator. *)

val is_call : Llvm.llvalue -> bool
(** check if a given LLVM instruction is a function call. *)

val is_input : Llvm.llvalue -> bool
(** [is_input instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [input]. *)

val is_print : Llvm.llvalue -> bool
(** [is_print instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [print]. *)

val is_print_num : Llvm.llvalue -> bool
(** [is_print_num instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [print_num]. *)

val is_print_ptr : Llvm.llvalue -> bool
(** [is_print_ptr instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [print_ptr]. *)

val is_print_mem : Llvm.llvalue -> bool
(** [is_print_mem instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [print_mem]. *)

val is_malloc : Llvm.llvalue -> bool
(** [is_malloc instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [malloc]. *)

val is_source : Llvm.llvalue -> bool
(** [is_source instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [source]. *)

val is_sink : Llvm.llvalue -> bool
(** [is_sink instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [sink]. *)

val is_sanitizer : Llvm.llvalue -> bool
(** [is_sanitizer instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is [sanitizer]. *)

val is_debug : Llvm.llvalue -> bool
(** [is_debug instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is a LLVM debug function. *)

val is_llvm_intrinsic : Llvm.llvalue -> bool
(** [is_llvm_intrinsic instr] checks if [instr] is [Llvm.Opcode.Call] and the callee is a LLVM intrinsic function. *)

val is_llvm_function : Llvm.llvalue -> bool

(** {2 Pretty printers} *)

val string_of_instr : Llvm.llvalue -> string
(** [string_of_instr i] returns the string representation of a LLVM instruction [i]. *)

val string_of_lhs : Llvm.llvalue -> string
(** [string_of_lhs i] returns the string representation of the lhs variable of a LLVM instruction [i]. *)

val string_of_exp : Llvm.llvalue -> string
(** [string_of_exp i] returns the string representation of a LLVM expression [i]. *)

val string_of_function : Llvm.llvalue -> string
(** [string_of_exp fn] returns the string representation of a LLVM expression of a function [fn]. *)

val string_of_location : Llvm.llcontext -> Llvm.llvalue -> string
(** [string_of_location ctx i] returns the string representation of the location of a LLVM instruction [i]. *)
