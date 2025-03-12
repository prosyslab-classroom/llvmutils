let string_cache = Hashtbl.create 2048

let string_of_llvalue_cache instr =
  if Hashtbl.mem string_cache instr then Hashtbl.find string_cache instr
  else
    let str = Llvm.string_of_llvalue instr |> String.trim in
    Hashtbl.add string_cache instr str;
    str

type debug_loc = {
  filename : string;
  funname : string;
  line : int;
  column : int;
}

let get_function instr = instr |> Llvm.instr_parent |> Llvm.block_parent

let debug_location llctx instr =
  let funname = get_function instr |> Llvm.value_name in
  let dbg = Llvm.metadata instr (Llvm.mdkind_id llctx "dbg") in
  match dbg with
  | Some s -> (
      let str = string_of_llvalue_cache s in
      let blk_mdnode = (Llvm.get_mdnode_operands s).(0) in
      let fun_mdnode = (Llvm.get_mdnode_operands blk_mdnode).(0) in
      let file_mdnode = (Llvm.get_mdnode_operands fun_mdnode).(0) in
      let filename = string_of_llvalue_cache file_mdnode in
      let filename = String.sub filename 2 (String.length filename - 3) in
      let r =
        Str.regexp "!DILocation(line: \\([0-9]+\\), column: \\([0-9]+\\)"
      in
      try
        let _ = Str.search_forward r str 0 in
        let line = Str.matched_group 1 str |> int_of_string in
        let column = Str.matched_group 2 str |> int_of_string in
        Some { filename; funname; line; column }
      with Not_found -> None)
  | None -> None

let string_of_instr = string_of_llvalue_cache

let string_of_lhs instr =
  let s = string_of_instr instr in
  let r = Str.regexp " = " in
  try
    let idx = Str.search_forward r s 0 in
    String.sub s 0 idx
  with Not_found ->
    prerr_endline ("Cannot find lhs of " ^ s);
    raise Not_found

let is_assignment = function
  | Llvm.Opcode.Invoke | Invalid2 | Add | FAdd | Sub | FSub | Mul | FMul | UDiv
  | SDiv | FDiv | URem | SRem | FRem | Shl | LShr | AShr | And | Or | Xor
  | Alloca | Load | GetElementPtr | Trunc | ZExt | SExt | FPToUI | FPToSI
  | UIToFP | SIToFP | FPTrunc | FPExt | PtrToInt | IntToPtr | BitCast | ICmp
  | FCmp | PHI | Select | UserOp1 | UserOp2 | VAArg | ExtractElement
  | InsertElement | ShuffleVector | ExtractValue | InsertValue | Call
  | LandingPad ->
      true
  | _ -> false

let is_binary_op = function
  | Llvm.Opcode.Add | FAdd | Sub | FSub | Mul | FMul | UDiv | SDiv | FDiv | URem
  | SRem | FRem | Shl | LShr | AShr | And | Or | Xor | ICmp | FCmp ->
      true
  | _ -> false

let is_unary_op = function
  | Llvm.Opcode.Trunc | ZExt | SExt | FPToUI | FPToSI | UIToFP | SIToFP
  | FPTrunc | FPExt | PtrToInt | IntToPtr | BitCast ->
      true
  | _ -> false

let is_assignment_instr instr =
  match Llvm.instr_opcode instr with
  | Llvm.Opcode.Call ->
      Llvm.type_of instr |> Llvm.classify_type <> Llvm.TypeKind.Void
  | op -> is_assignment op

let is_phi instr =
  match Llvm.instr_opcode instr with Llvm.Opcode.PHI -> true | _ -> false

let is_argument exp =
  match Llvm.classify_value exp with
  | Llvm.ValueKind.Argument -> true
  | _ -> false

let is_call instr =
  match Llvm.instr_opcode instr with Llvm.Opcode.Call -> true | _ -> false

let string_of_exp exp =
  match Llvm.classify_value exp with
  | Llvm.ValueKind.NullValue -> "0"
  | BasicBlock | InlineAsm | MDNode | MDString | BlockAddress
  | ConstantAggregateZero | ConstantArray | ConstantDataArray
  | ConstantDataVector | ConstantExpr ->
      string_of_llvalue_cache exp
  | Argument | ConstantFP | ConstantInt ->
      let s = string_of_instr exp in
      let r = Str.regexp " " in
      let idx = Str.search_forward r s 0 in
      String.sub s (idx + 1) (String.length s - idx - 1)
  | ConstantPointerNull -> "0"
  | ConstantStruct | ConstantVector -> string_of_llvalue_cache exp
  | Function -> Llvm.value_name exp
  | GlobalIFunc | GlobalAlias -> string_of_llvalue_cache exp
  | GlobalVariable -> Llvm.value_name exp
  | UndefValue -> "undef"
  | PoisonValue -> "poison"
  | Instruction i when is_assignment i -> string_of_lhs exp
  | Instruction _ -> string_of_instr exp

let string_of_function = Llvm.value_name

let iter_all_instr f m =
  Llvm.iter_functions
    (fun func ->
      if Llvm.is_declaration func then ()
      else Llvm.iter_blocks (Llvm.iter_instrs f) func)
    m

let fold_left_all_instr f a m =
  Llvm.fold_left_functions
    (fun a func ->
      if Llvm.is_declaration func then a
      else
        Llvm.fold_left_blocks
          (fun a blk -> Llvm.fold_left_instrs (fun a instr -> f a instr) a blk)
          a func)
    a m

let string_of_location llctx instr =
  match debug_location llctx instr with
  | Some s ->
      s.filename ^ ":" ^ s.funname ^ ":" ^ string_of_int s.line ^ ":"
      ^ string_of_int s.column
  | None ->
      let funname = get_function instr |> Llvm.value_name in
      funname ^ ":0:0"

let function_name instr =
  let callee_expr = Llvm.operand instr (Llvm.num_operands instr - 1) in
  Llvm.value_name callee_expr

let is_input instr =
  if is_call instr then function_name instr = "input" else false

let is_print instr =
  if is_call instr then function_name instr = "print" else false

let is_print_num instr =
  if is_call instr then function_name instr = "print_num" else false

let is_print_ptr instr =
  if is_call instr then function_name instr = "print_ptr" else false

let is_print_mem instr =
  if is_call instr then function_name instr = "print_mem" else false

let is_malloc instr =
  if is_call instr then function_name instr = "malloc" else false

let is_source instr =
  if is_call instr then function_name instr = "source" else false

let is_sink instr =
  if is_call instr then function_name instr = "sink" else false

let is_sanitizer instr =
  if is_call instr then function_name instr = "sanitizer" else false

let is_assume instr =
  if is_call instr then function_name instr = "assume" else false

let is_assert_fail instr =
  if is_call instr then function_name instr = "__assert_fail" else false

let is_llvm_function f =
  let r1 = Str.regexp "llvm\\.dbg\\..+" in
  let r2 = Str.regexp "llvm\\.lifetime\\..+" in
  Str.string_match r1 (Llvm.value_name f) 0
  || Str.string_match r2 (Llvm.value_name f) 0

let find_main llm =
  match Llvm.lookup_function "main" llm with
  | Some f -> f
  | None -> failwith "main funtion not found"

let entry_point f = Llvm.entry_block f |> Llvm.instr_begin

let is_debug instr =
  if is_call instr then
    let callee_expr = Llvm.operand instr (Llvm.num_operands instr - 1) in
    let r1 = Str.regexp "llvm\\.dbg\\..+" in
    Str.string_match r1 (Llvm.value_name callee_expr) 0
  else false

let is_llvm_intrinsic instr =
  if is_call instr then
    let callee_expr = Llvm.operand instr (Llvm.num_operands instr - 1) in
    is_llvm_function callee_expr
  else false

let first_label f =
  let rec get_label pos =
    match pos with
    | Llvm.At_end _ -> failwith "unreachable"
    | Llvm.Before instr ->
        if not (is_debug instr) then pos
        else get_label (Llvm.instr_succ instr)
  in
  Llvm.entry_block f |> Llvm.instr_begin |> get_label

let neg_pred = function
  | Llvm.Icmp.Eq -> Llvm.Icmp.Ne
  | Llvm.Icmp.Ne -> Llvm.Icmp.Eq
  | Llvm.Icmp.Slt -> Llvm.Icmp.Sge
  | Llvm.Icmp.Ult -> Llvm.Icmp.Uge
  | Llvm.Icmp.Sle -> Llvm.Icmp.Sgt
  | Llvm.Icmp.Ule -> Llvm.Icmp.Ugt
  | Llvm.Icmp.Sgt -> Llvm.Icmp.Sle
  | Llvm.Icmp.Ugt -> Llvm.Icmp.Ule
  | Llvm.Icmp.Sge -> Llvm.Icmp.Slt
  | Llvm.Icmp.Uge -> Llvm.Icmp.Ult

let flip_pred = function
  | Llvm.Icmp.Eq -> Llvm.Icmp.Eq
  | Llvm.Icmp.Ne -> Llvm.Icmp.Ne
  | Llvm.Icmp.Slt -> Llvm.Icmp.Sgt
  | Llvm.Icmp.Ult -> Llvm.Icmp.Ugt
  | Llvm.Icmp.Sle -> Llvm.Icmp.Sge
  | Llvm.Icmp.Ule -> Llvm.Icmp.Uge
  | Llvm.Icmp.Sgt -> Llvm.Icmp.Slt
  | Llvm.Icmp.Ugt -> Llvm.Icmp.Ult
  | Llvm.Icmp.Sge -> Llvm.Icmp.Sle
  | Llvm.Icmp.Uge -> Llvm.Icmp.Ule

let rec get_next_nonphi instr =
  let next = Llvm.instr_succ instr in
  match next with
  | Llvm.At_end _ -> raise Not_found
  | Llvm.Before next_instr -> (
      match Llvm.instr_opcode next_instr with
      | Llvm.Opcode.PHI -> get_next_nonphi next_instr
      | _ -> next)

let get_next_phi instr =
  let next = Llvm.instr_succ instr in
  match next with
  | Llvm.At_end _ -> raise Not_found
  | Llvm.Before next_instr -> (
      match Llvm.instr_opcode next_instr with
      | Llvm.Opcode.PHI -> next
      | _ -> raise Not_found)
