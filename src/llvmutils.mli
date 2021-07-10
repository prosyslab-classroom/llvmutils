(** {2 Debug information} *)

type debug_loc = {
  filename : string;
  funname : string;
  line : int;
  column : int;
}

val debug_location : Llvm.llcontext -> Llvm.llvalue -> debug_loc option

(** {2 Helper functions} *)

val fold_left_all_instr :
  ('a -> Llvm.llvalue -> 'a) -> 'a -> Llvm.llmodule -> 'a
(** [fold_left_all_instr f a m] returns [f (... f (f (f a i1) i2) i3 ...) in], where [i1..in] are the instructions in [m]. *)

val find_main : Llvm.llmodule -> Llvm.llvalue
(** return a function with name [main] in given llmodule. If no such function exists, [failwith "main funtion not found"]. *)

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

val is_input : Llvm.llvalue -> bool
(** when given llvalue is [Llvm.Opcode.Call], check if a callee is [input]. If not [Llvm.Opcode.Call], undefined behavior. *)

val is_print : Llvm.llvalue -> bool
(** when given llvalue is [Llvm.Opcode.Call], check if a callee is [print]. If not [Llvm.Opcode.Call], undefined behavior. *)

val is_source : Llvm.llvalue -> bool
(** when given llvalue is [Llvm.Opcode.Call], check if a callee is [source]. If not [Llvm.Opcode.Call], undefined behavior. *)

val is_sink : Llvm.llvalue -> bool
(** when given llvalue is [Llvm.Opcode.Call], check if a callee is [sink]. If not [Llvm.Opcode.Call], undefined behavior. *)

val is_sanitizer : Llvm.llvalue -> bool
(** when given llvalue is [Llvm.Opcode.Call], check if a callee is [sanitizer]. If not [Llvm.Opcode.Call], undefined behavior. *)

val is_llvm_function : Llvm.llvalue -> bool

val is_llvm_intrinsic : Llvm.llvalue -> bool
(** check if a given LLVM instruction is a LLVM intrinsic function. *)

(** {2 Pretty printers} *)

val string_of_instr : Llvm.llvalue -> string
(** [string_of_instr i] returns the string representation of a LLVM instruction [i]. *)

val string_of_lhs : Llvm.llvalue -> string
(** [string_of_lhs i] returns the string representation of the lhs variable of a LLVM instruction [i]. *)

val string_of_exp : Llvm.llvalue -> string
(** [string_of_exp i] returns the string representation of a LLVM expression [i]. *)

val string_of_location : Llvm.llcontext -> Llvm.llvalue -> string
(** [string_of_location ctx i] returns the string representation of the location of a LLVM instruction [i]. *)
