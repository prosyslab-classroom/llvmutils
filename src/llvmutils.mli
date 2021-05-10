(** {2 Debug information} *)

type debug_loc = {
  filename : string;
  funname : string;
  line : int;
  column : int;
}

val debug_location : Llvm.llcontext -> Llvm.llvalue -> debug_loc option

(** {2 Test functions} *)

val is_assignment : Llvm.Opcode.t -> bool
(** check if a given LLVM instruction is an assignment. *)

val is_phi : Llvm.llvalue -> bool
(** check if a given LLVM instruction is a phi node. *)

val is_unary_op : Llvm.Opcode.t -> bool
(** check if a given LLVM instruction is a unary operator. *)

val is_binary_op : Llvm.Opcode.t -> bool
(** check if a given LLVM instruction is a binary operator. *)

val is_source : Llvm.llvalue -> bool

val is_sink : Llvm.llvalue -> bool

val is_sanitizer : Llvm.llvalue -> bool

val is_llvm_function : Llvm.llvalue -> bool

(** {2 Pretty printers} *)

val string_of_instr : Llvm.llvalue -> string
(** [string_of_instr i] returns the string representation of a LLVM instruction [i]. *)

val string_of_lhs : Llvm.llvalue -> string
(** [string_of_lhs i] returns the string representation of the lhs variable of a LLVM instruction [i]. *)

val string_of_exp : Llvm.llvalue -> string
(** [string_of_exp i] returns the string representation of a LLVM expression [i]. *)
