%skeleton "lalr1.cc"
%require  "3.0.1"

%defines 
%define api.namespace {IPL}
%define api.parser.class {Parser}

%define parse.trace

%code requires{
   namespace IPL {
      class Scanner;
   }
   #include "type.hh"
   #include "symbtab.hh"
   #include "ast.hh"
   #include "location.hh"
}

%printer { std::cerr << $$; } CONSTANT_STRING
%printer { std::cerr << $$; } CONSTANT_INT
%printer { std::cerr << $$; } VOID
%printer { std::cerr << $$; } INT
%printer { std::cerr << $$; } STRUCT
%printer { std::cerr << $$; } FOR
%printer { std::cerr << $$; } WHILE
%printer { std::cerr << $$; } IF
%printer { std::cerr << $$; } ELSE
%printer { std::cerr << $$; } RETURN
%printer { std::cerr << $$; } MAIN
%printer { std::cerr << $$; } PRINTF
%printer { std::cerr << $$; } IDENTIFIER
%printer { std::cerr << $$; } OP_GTE
%printer { std::cerr << $$; } OP_LTE
%printer { std::cerr << $$; } OP_EQ
%printer { std::cerr << $$; } OP_NEQ
%printer { std::cerr << $$; } OP_AND
%printer { std::cerr << $$; } OP_OR
%printer { std::cerr << $$; } OP_INC
%printer { std::cerr << $$; } OP_PTR
%printer { std::cerr << $$; } OP_NOT
%printer { std::cerr << $$; } OP_ADDR
%printer { std::cerr << $$; } OP_GT
%printer { std::cerr << $$; } OP_LT
%printer { std::cerr << $$; } OP_ADD
%printer { std::cerr << $$; } OP_SUB
%printer { std::cerr << $$; } OP_MUL
%printer { std::cerr << $$; } OP_DIV
%printer { std::cerr << $$; } OP_ASSIGN
%printer { std::cerr << $$; } OP_MEM
%printer { std::cerr << $$; } COMMA
%printer { std::cerr << $$; } EOS
%printer { std::cerr << $$; } LRB
%printer { std::cerr << $$; } RRB
%printer { std::cerr << $$; } LCB
%printer { std::cerr << $$; } RCB
%printer { std::cerr << $$; } LSB
%printer { std::cerr << $$; } RSB
%printer { std::cerr << $$; } OTHERS
%printer { std::cerr << $$; } FLOAT
%printer { std::cerr << $$; } CONSTANT_FLOAT

%parse-param { Scanner  &scanner  }
%locations
%code{
   #include <iostream>
      
   #include "scanner.hh"

   #undef yylex
   #define yylex IPL::Parser::scanner.yylex
   using namespace IPL;
   GST* gst = new GST();
   LST* current_lst = NULL;
   int current_offset = 0;
   int return_offset = 0;
   std::map<std::string, compound_statement*> func_ast_map;
   Category current_category = Category::Const;
   Type* current_return_type = NULL;
   void generate_code(){
      for(auto it = func_ast_map.begin(); it != func_ast_map.end(); it++) {
         if(it->second){
            it->second->generate_code(it->first);
            std::cout << std::endl;
         }
      }
   }
}

%define api.value.type variant
%define parse.assert

%token '\n' '\t'
%token <std::string> CONSTANT_STRING
%token <std::string> CONSTANT_INT
%token <std::string> VOID
%token <std::string> INT
%token <std::string> STRUCT
%token <std::string> FOR
%token <std::string> WHILE
%token <std::string> IF
%token <std::string> ELSE
%token <std::string> RETURN
%token <std::string> MAIN
%token <std::string> PRINTF
%token <std::string> IDENTIFIER
%token <std::string> OP_GTE
%token <std::string> OP_LTE
%token <std::string> OP_EQ
%token <std::string> OP_NEQ
%token <std::string> OP_AND
%token <std::string> OP_OR
%token <std::string> OP_INC
%token <std::string> OP_PTR
%token <std::string> OP_NOT
%token <std::string> OP_ADDR
%token <std::string> OP_GT
%token <std::string> OP_LT
%token <std::string> OP_ADD
%token <std::string> OP_SUB
%token <std::string> OP_MUL
%token <std::string> OP_DIV
%token <std::string> OP_ASSIGN
%token <std::string> OP_MEM
%token <std::string> COMMA
%token <std::string> EOS
%token <std::string> LRB
%token <std::string> RRB
%token <std::string> LCB
%token <std::string> RCB
%token <std::string> LSB
%token <std::string> RSB
%token <std::string> OTHERS
%token <std::string> FLOAT
%token <std::string> CONSTANT_FLOAT
%token <std::string> EOFILE

%nterm <int> program
%nterm <int> main_definition
%nterm <int> translation_unit
%nterm <int> struct_specifier
%nterm <int> function_definition
%nterm <Type*> type_specifier
%nterm <int> declaration_list
%nterm <int> declaration
%nterm <DeclaratorList*> declarator_list
%nterm <Declarator*> declarator
%nterm <Declarator*> declarator_arr
%nterm <ParameterList*> parameter_list
%nterm <Parameter*> parameter_declaration

%nterm <compound_statement*> compound_statement
%nterm <seq_astnode*> statement_list
%nterm <statement_astnode*> statement
%nterm <if_astnode*> selection_statement
%nterm <iteration_astnode*> iteration_statement
%nterm <proccall_astnode*> procedure_call
%nterm <printf_astnode*> printf_call
%nterm <expression_list*> expression_list
%nterm <expression_astnode*> expression
%nterm <assignE_astnode*> assignment_expression
%nterm <expression_astnode*> logical_and_expression
%nterm <expression_astnode*> equality_expression
%nterm <expression_astnode*> relational_expression
%nterm <expression_astnode*> additive_expression
%nterm <expression_astnode*> multiplicative_expression
%nterm <expression_astnode*> unary_expression
%nterm <expression_astnode*> postfix_expression
%nterm <expression_astnode*> primary_expression
%nterm <OP_Unary> unary_operator

%start program

%%

program
: main_definition {
   // gst->print();
   generate_code();
}
| translation_unit main_definition{
   // gst->print();
   generate_code();
}

translation_unit
: struct_specifier 
| function_definition
| translation_unit struct_specifier
| translation_unit function_definition

struct_specifier
: STRUCT IDENTIFIER {
   LST* lst = new LST();
   GST_Entry* gst_entry = new GST_Entry(
      $1+" "+$2,
      Category::Struct,
      Scope::Global,
      new Type(BaseType::Null),
      0,
      0,
      lst
   );
   bool success = gst->addEntry(gst_entry);
   if(!success) {
      error(@1, "The struct \"" + $2 + "\" has a previous declaration");
   }
   current_lst = lst;
   current_offset = 0;
   current_category = Category::Struct;
} LCB declaration_list RCB EOS {
   GST_Entry* gst_entry = gst->getEntry($1+" "+$2);
   gst_entry->setSize(gst_entry->getLST()->getLocalVarSize());
   current_lst = NULL;
   current_offset = 0;
   current_category = Category::Const;
}

function_definition
: type_specifier IDENTIFIER LRB RRB {
   LST* lst = new LST();
   GST_Entry* gst_entry = new GST_Entry(
      $2,
      Category::Function,
      Scope::Global,
      $1,
      0,
      0,
      lst
   );
   bool success = gst->addEntry(gst_entry);
   if(!success) {
      error(@1, "The function \"" + $2 + "\" has a previous defination");
   }
   current_lst = lst;
   current_offset = 0;
   return_offset = 8;
   current_category = Category::Function;
   current_return_type = $1;
} compound_statement {
   func_ast_map[$2] = $6;
   current_lst = NULL;
   current_offset = 0;
   current_category = Category::Const;
   current_return_type = nullptr;
}
| type_specifier IDENTIFIER LRB {
   LST* lst = new LST();
   GST_Entry* gst_entry = new GST_Entry(
      $2,
      Category::Function,
      Scope::Global,
      $1,
      0,
      0,
      lst
   );
   bool success = gst->addEntry(gst_entry);
   if(!success) {
      error(@1, "The function \"" + $2 + "\" has a previous defination");
   }
   current_lst = lst;
   current_offset = 8;
} parameter_list {
   std::vector <Parameter*> parameters = $5->getParameters();
   for(unsigned int i = 0; i < parameters.size(); i++) {
      Parameter* parameter = parameters[i];
      Type* type = parameter->getType();
      if(type->get_base_type() == BaseType::Void) {
         error(@1, "The variable \"" + parameter->getName() + "\" cannot be of type void");
      }
      int size = type->get_base_type() == BaseType::Array ? 4 : type->get_size();
      LST_Entry* lst_entry = new LST_Entry(
         parameter->getName(),
         Category::Variable,
         Scope::Param,
         type,
         size,
         current_offset
      );
      current_offset += size;
      bool success = current_lst->addEntry(lst_entry);
      if(!success) {
         error(@1, "The variable \"" + parameter->getName() + "\" has a previous declaration");
      }
   }
} RRB {
   return_offset = current_offset;
   current_offset = 0;
   current_category = Category::Function;
   current_return_type = $1;
} compound_statement {
   func_ast_map[$2] = $9;
   current_lst = NULL;
   current_offset = 0;
   current_category = Category::Const;
   current_return_type = nullptr;
}

main_definition
: INT MAIN LRB RRB {
   LST* lst = new LST();
   GST_Entry* gst_entry = new GST_Entry(
      $2,
      Category::Function,
      Scope::Global,
      new Type(BaseType::Int),
      0,
      0,
      lst
   );
   bool success = gst->addEntry(gst_entry);
   if(!success) {
      error(@1, "Multiple defination of main function");
   }
   current_lst = lst;
   current_offset = 0;
   return_offset = -1;
   current_category = Category::Function;
   current_return_type = new Type(BaseType::Int);
} compound_statement {
   func_ast_map[$2] = $6;
   current_lst = NULL;
   current_offset = 0;
   current_category = Category::Const;
   current_return_type = nullptr;
}

type_specifier
: VOID {
   $$ = new Type(BaseType::Void);
}
| INT {
   $$ = new Type(BaseType::Int);
   $$->set_size(4);
}
| STRUCT IDENTIFIER {
   GST_Entry* gst_entry = gst->getEntry($1+" "+$2);
   if(gst_entry == NULL) {
      error(@1, "The struct \"" + $2 + "\" has no previous declaration");
   }
   $$ = new Type(BaseType::Struct, $1+" "+$2);
   $$->set_size(gst_entry->getSize());
}

parameter_list
: parameter_declaration {
   $$ = new ParameterList();
   $$->addParameter($1);
}
| parameter_list COMMA parameter_declaration {
   $$ = $1;
   $$->addParameter($3);
}

parameter_declaration
: type_specifier declarator {
   Type* type = generate_type($1, $2->getStars(), $2->getArrays());
   $$ = new Parameter(type, $2->getName());
}

declaration_list
: declaration
| declaration_list declaration

declaration
: type_specifier declarator_list EOS {
   std::vector<Declarator*> declarators = $2->getDeclarators();
   for(unsigned int i=0; i<declarators.size(); i++) {
      Declarator* declarator = declarators[i];
      std::string name = declarator->getName();
      Type* type = generate_type($1, declarator->getStars(), declarator->getArrays());
      if(type->get_base_type() == BaseType::Void) {
         error(@1, "The variable \"" + name + "\" cannot be of type void");
      }
      if(current_category == Category::Function) {
         current_offset -= type->get_recursive_size();
      }
      LST_Entry* lst_entry = new LST_Entry(
         name,
         Category::Variable,
         Scope::Local,
         type,
         type->get_recursive_size(),
         current_offset
      );
      if(current_category == Category::Struct) {
         current_offset += type->get_recursive_size();
      }
      bool success = current_lst->addEntry(lst_entry);
      if(!success) {
         error(@1, "The variable \"" + name + "\" has a previous declaration");
      }
   }
}

declarator_list
: declarator {
   $$ = new DeclaratorList();
   $$->addDeclarator($1);
}
| declarator_list COMMA declarator {
   $$ = $1;
   $$->addDeclarator($3);
}

declarator
: declarator_arr{
   $$ = $1;
}
| OP_MUL declarator{
   $$ = $2;
   $$->setStars($$->getStars()+1);
}

declarator_arr
: IDENTIFIER {
   $$ = new Declarator($1);
}
| declarator_arr LSB CONSTANT_INT RSB {
   $$ = $1;
   $$->addToArray(stoi($3));
}

compound_statement
: LCB RCB { 
   $$ = nullptr; 
}
| LCB statement_list RCB {
   $$ = new compound_statement($2, 0, current_return_type->get_base_type()==BaseType::Void);
}
| LCB declaration_list statement_list RCB { 
   int size = current_lst->getLocalVarSize();
   $$ = new compound_statement($3, size, current_return_type->get_base_type()==BaseType::Void); 
}

statement_list
: statement {
   $$ = new seq_astnode();
   $$->add_statement($1);
}
| statement_list statement {
   $$ = $1;
   $$->add_statement($2);
}

statement
: EOS { $$ = new empty_astnode(); }
| LCB statement_list RCB { $$ = $2; }
| assignment_expression EOS { $$ = new assignS_astnode($1); }
| selection_statement { $$ = $1; }
| iteration_statement { $$ = $1; }
| procedure_call { $$ = $1; }
| printf_call { $$ = $1; }
| RETURN expression EOS { 
   // TODO: check if return type is correct 
   $$ = new return_astnode($2, return_offset, current_lst->getLocalVarSize());
}

assignment_expression
: unary_expression OP_ASSIGN expression { 
   // TODO: check if types are correct
   if($1->get_is_lvalue()) {
      if($1->get_type()->get_base_type() == BaseType::Void) {
         error(@1, "Cannot assign to a variable of type void");
      }
      else if (are_compatible($1->get_type(), $3->get_type()) == nullptr) {
         error(@1, "The types of the operands of the operator \"=\" are not compatible");
      }
      $$ = new assignE_astnode($1, $3); 
      $$->set_type(new Type(BaseType::Null));
      $$->set_is_lvalue(false);
   }
   else{
      error(@1, "Cannot assign to a non-lvalue");
   }
}

expression
: logical_and_expression { $$ = $1; }
| expression OP_OR logical_and_expression { 
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_OR);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_OR);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"||\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false); 
}

logical_and_expression
: equality_expression { $$ = $1; }
| logical_and_expression OP_AND equality_expression { 
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_AND); 
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_AND);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"&&\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}

equality_expression
: relational_expression { $$ = $1; }
| equality_expression OP_EQ relational_expression { 
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_EQ);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_EQ);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"==\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);

}
| equality_expression OP_NEQ relational_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_NEQ);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_NEQ);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"!=\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}

relational_expression
: additive_expression { $$ = $1; }
| relational_expression OP_LT additive_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_LT);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_LT);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"<\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}
| relational_expression OP_GT additive_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_GT);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_GT);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \">\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}
| relational_expression OP_LTE additive_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_LTE);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_LTE);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"<=\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}
| relational_expression OP_GTE additive_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_GTE);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_GTE);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \">=\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}

additive_expression
: multiplicative_expression { $$ = $1; }
| additive_expression OP_ADD multiplicative_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_ADD);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_ADD);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"+\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}
| additive_expression OP_SUB multiplicative_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_SUB);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_SUB);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"-\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}

multiplicative_expression
: unary_expression { $$ = $1; }
| multiplicative_expression OP_MUL unary_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_MUL);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_MUL);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"*\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}
| multiplicative_expression OP_DIV unary_expression {
   // TODO: check if types are correct
   $$ = new op_binary_astnode($1, $3, OP_Binary::OP_DIV);
   Type* compatible_type = are_compatible($1->get_type(), $3->get_type(), OP_Binary::OP_DIV);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"/\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}

unary_expression
: postfix_expression { $$ = $1; }
| unary_operator unary_expression {
   // TODO: check if types are correct
   $$ = new op_unary_astnode($2, $1);
   Type* compatible_type = are_compatible($2->get_type(), $1);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"-\" are not compatible");
   }
   $$->set_type(compatible_type);
   switch($1) {
      case OP_Unary::OP_MUL:
         $$->set_is_lvalue(true);
         break;
      default:
         $$->set_is_lvalue(false);
         break;
   }
}

postfix_expression
: primary_expression { $$ = $1; }
| postfix_expression OP_INC { 
   // TODO: check if types are correct
   $$ = new op_unary_astnode($1, OP_Unary::OP_INC);
   Type* compatible_type = are_compatible($1->get_type(), OP_Unary::OP_INC);
   if(compatible_type == nullptr) {
      error(@1, "The types of the operands of the operator \"++\" are not compatible");
   }
   $$->set_type(compatible_type);
   $$->set_is_lvalue(false);
}
| IDENTIFIER LRB RRB {
   // TODO: check if params are correct
   GST_Entry* entry = gst->getEntry($1);
   if(entry == nullptr) {
      error(@1, "The function \"" + $1 + "\" is not declared");
   }
   $$ = new funcall_astnode($1,entry->getLST()->getLocalParamSize());
   $$->set_type(entry->getType());
   $$->set_is_lvalue(false);
}
| IDENTIFIER LRB expression_list RRB {
   // TODO: check if params and thier types are correct
   std::vector<expression_astnode*> expressions = $3->get_expressions();
   GST_Entry* entry = gst->getEntry($1);
   funcall_astnode* output = new funcall_astnode($1,entry->getLST()->getLocalParamSize());
   if(entry == nullptr) {
      error(@1, "The function \"" + $1 + "\" is not declared");
   }
   for (unsigned int i = 0; i < expressions.size(); i++) {
      output->add_argument(expressions[i]);
   }
   $$ = output;
   $$->set_type(entry->getType());
   $$->set_is_lvalue(false);
}
| postfix_expression OP_MEM IDENTIFIER {
   // TODO: check if types are correct
   // TODO: check if identifier is declared and offset is correct
   if($1->get_type()->get_base_type() != BaseType::Struct) {
      error(@1, "The type of the operand of the operator \".\" is not a struct");
   }
   GST_Entry* entry = gst->getEntry($1->get_type()->get_name());
   if(entry == nullptr) {
      error(@1, "The struct \"" + $1->get_type()->get_name() + "\" is not declared");
   }
   LST_Entry* member = entry->getLST()->getEntry($3);
   if(member == nullptr) {
      error(@1, "The member \"" + $3 + "\" is not declared");
   }
   $$ = new member_astnode($1, new identifier_astnode($3, member->getOffset(), member->getScope()));
   $$->set_type(member->getType());
   $$->set_is_lvalue($1->get_is_lvalue());
}
| postfix_expression OP_PTR IDENTIFIER {
   // TODO: check if types are correct
   // TODO: check if identifier is declared and offset is correct
   if($1->get_type()->get_base_type() == BaseType::Pointer && $1->get_type()->get_sub_type()->get_base_type() == BaseType::Struct) {
      GST_Entry* entry = gst->getEntry($1->get_type()->get_sub_type()->get_name());
      if(entry == nullptr) {
         error(@1, "The struct \"" + $1->get_type()->get_sub_type()->get_name() + "\" is not declared");
      }
      LST_Entry* member = entry->getLST()->getEntry($3);
      if(member == nullptr) {
         error(@1, "The member \"" + $3 + "\" is not declared");
      }
      $$ = new arrow_astnode($1, new identifier_astnode($3, member->getOffset(), member->getScope()));
      $$->set_type(member->getType());
      $$->set_is_lvalue($1->get_is_lvalue());
   }
   else{
      error(@1, "The type of the operand of the operator \"->\" is not a struct");
   }
}
| postfix_expression LSB expression RSB {
   // TODO: check if types are correct
   if($1->get_type()->get_base_type() != BaseType::Array && $1->get_type()->get_base_type() != BaseType::Pointer) {
      error(@1, "The type of the operand of the operator \"[]\" is not an array or a pointer");
   }
   if($3->get_type()->get_base_type() != BaseType::Int) {
      error(@1, "The type of the index of the operator \"[]\" is not an int");
   }
   $$ = new array_astnode($1, $3);
   $$->set_type($1->get_type()->get_sub_type());
   $$->set_is_lvalue(true);
}

primary_expression
: IDENTIFIER {
   // TODO: check if identifier is declared
   LST_Entry* entry = current_lst->getEntry($1);
   if(entry == nullptr) {
      error(@1, "The identifier \"" + $1 + "\" is not declared");
   }
   int offset = entry->getOffset();
   $$ = new identifier_astnode($1, offset, entry->getScope());
   $$->set_type(entry->getType());
   $$->set_is_lvalue(true);
}
| CONSTANT_INT {
   $$ = new int_astnode(stoi($1));
   $$->set_type(new Type(BaseType::Int));
   $$->set_is_lvalue(false);
}
| LRB expression RRB { $$ = $2; }

unary_operator
: OP_SUB { $$ = OP_Unary::OP_SUB; }
| OP_NOT { $$ = OP_Unary::OP_NOT; }
| OP_ADDR { $$ = OP_Unary::OP_ADDR; }
| OP_MUL { $$ = OP_Unary::OP_MUL; }

selection_statement
: IF LRB expression RRB statement ELSE statement {
   $$ = new if_astnode($3, $5, $7);
}

iteration_statement
: WHILE LRB expression RRB statement {
   $$ = new while_astnode($3, $5);
}
| FOR LRB assignment_expression EOS expression EOS assignment_expression RRB statement {
   $$ = new for_astnode($3, $5, $7, $9);
}

procedure_call
: IDENTIFIER LRB RRB EOS { 
   GST_Entry* entry = gst->getEntry($1);
   $$ = new proccall_astnode($1, entry->getLST()->getLocalParamSize(),entry->getType()->get_size());
}
| IDENTIFIER LRB expression_list RRB EOS { 
   // TODO: check if params and thier types are correct
   GST_Entry* entry = gst->getEntry($1);
   $$ = new proccall_astnode($1, entry->getLST()->getLocalParamSize(),entry->getType()->get_size());
   std::vector<expression_astnode*> expressions = $3->get_expressions();
   for (unsigned int i = 0; i < expressions.size(); i++) {
      $$->add_argument(expressions[i]);
   }
}

printf_call
: PRINTF LRB CONSTANT_STRING RRB EOS {
   $$ = new printf_astnode(new string_astnode($3),0); 
}
| PRINTF LRB CONSTANT_STRING COMMA expression_list RRB EOS { 
   // TODO: check if params and thier types are correct
   std::vector<expression_astnode*> expressions = $5->get_expressions();
   int param_size = 0;
   for (unsigned int i = 0; i < expressions.size(); i++) {
      param_size += expressions[i]->get_type()->get_size();
   }
   $$ = new printf_astnode(new string_astnode($3),param_size);
   for (unsigned int i = 0; i < expressions.size(); i++) {
      $$->add_argument(expressions[i]);
   }
}

expression_list
: expression {
   $$ = new expression_list();
   $$->add_expression($1);
}
| expression_list COMMA expression {
   $$ = $1;
   $$->add_expression($3);
}

%%

void 
IPL::Parser::error( const location_type &l, const std::string &err_message )
{
   std::cout << "Error at line " << l.begin.line << ": " << err_message <<"\n";
   exit(1);
}

